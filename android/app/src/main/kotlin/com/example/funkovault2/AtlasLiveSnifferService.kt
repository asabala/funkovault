package com.example.funkovault2

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.RectF
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.SystemClock
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.objects.DetectedObject
import com.google.mlkit.vision.objects.ObjectDetection
import com.google.mlkit.vision.objects.ObjectDetector
import com.google.mlkit.vision.objects.defaults.ObjectDetectorOptions
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.google.android.gms.tasks.Tasks
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicLong

class AtlasLiveSnifferService : Service() {
    companion object {
        const val ACTION_START = "com.example.funkovault2.action.START_LIVE_SNIFFER"
        const val ACTION_STOP = "com.example.funkovault2.action.STOP_LIVE_SNIFFER"
        const val ACTION_UPDATE_HUD = "com.example.funkovault2.action.UPDATE_LIVE_SNIFFER_HUD"
        const val EXTRA_RESULT_CODE = "result_code"
        const val EXTRA_RESULT_DATA = "result_data"
        const val EXTRA_HUD_TEXT = "hud_text"

        private const val NOTIFICATION_CHANNEL_ID = "atlas_live_sniffer"
        private const val NOTIFICATION_ID = 6201
        private const val MIN_RECOGNITION_INTERVAL_MS = 250L
        private const val TRACKER_LONG_EDGE = 640

        @Volatile
        private var activeInstance: AtlasLiveSnifferService? = null

        fun updateHudIfActive(
            text: String,
            showScanChoices: Boolean = false,
            detectedCount: Int = 0,
        ): Boolean {
            val service = activeInstance ?: return false
            service.updateOverlayState(text, showScanChoices, detectedCount)
            return true
        }
    }

    private data class TargetTrackingConfig(
        val coastMs: Long = 600L,
        val lostMs: Long = 1500L,
        val bootstrapEvidenceMs: Long = 850L,
        val roiPaddingFraction: Float = 0.15f,
        val reacquireMinIou: Double = 0.18,
        val reacquireMaxCenterDistanceSquared: Float = 0.025f,
    )

    private val targetTrackingConfig = TargetTrackingConfig()

    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private var captureThread: HandlerThread? = null
    private var captureHandler: Handler? = null

    private var windowManager: WindowManager? = null
    private var overlayView: LinearLayout? = null
    private var overlayTextView: TextView? = null
    private var overlayChoiceRow: LinearLayout? = null
    private var targetPickerView: View? = null
    private var targetReticleView: View? = null

    @Volatile private var targetSelectionActive: Boolean = false
    @Volatile private var singleTargetMode: Boolean = false
    @Volatile private var pendingTargetX: Double? = null
    @Volatile private var pendingTargetY: Double? = null
    @Volatile private var lockedTrackId: Int? = null
    @Volatile private var trackedBounds: RectF? = null
    @Volatile private var targetGeneration: Int = 0
    @Volatile private var targetState: String = "none"
    @Volatile private var lastTargetSeenElapsedMs: Long = 0L
    @Volatile private var reacquireCandidateTrackId: Int? = null
    @Volatile private var reacquireCandidateHits: Int = 0

    private val recognitionInFlight = AtomicBoolean(false)
    private val frameSequence = AtomicLong(0L)
    private var lastRecognitionAtElapsedMs: Long = 0L

    private val textRecognizer: TextRecognizer by lazy {
        TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    }

    private val barcodeScanner: BarcodeScanner by lazy {
        val options = BarcodeScannerOptions.Builder()
            .setBarcodeFormats(
                Barcode.FORMAT_UPC_A,
                Barcode.FORMAT_UPC_E,
                Barcode.FORMAT_EAN_8,
                Barcode.FORMAT_EAN_13,
                Barcode.FORMAT_QR_CODE,
            )
            .build()
        BarcodeScanning.getClient(options)
    }

    private val objectDetector: ObjectDetector by lazy {
        val options = ObjectDetectorOptions.Builder()
            .setDetectorMode(ObjectDetectorOptions.STREAM_MODE)
            .enableMultipleObjects()
            .build()
        ObjectDetection.getClient(options)
    }

    private val projectionCallback = object : MediaProjection.Callback() {
        override fun onStop() {
            stopSelfSafely()
        }
    }

    override fun onCreate() {
        super.onCreate()
        activeInstance = this
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelfSafely()
                return START_NOT_STICKY
            }
            ACTION_UPDATE_HUD -> {
                val text = intent.getStringExtra(EXTRA_HUD_TEXT)?.trim().orEmpty()
                if (text.isNotEmpty()) {
                    AtlasLiveSnifferStateStore.hudText = text
                    updateOverlayText(text)
                }
                return START_NOT_STICKY
            }
            ACTION_START -> startLiveSniffer(intent)
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        releaseCapture()
        removeOverlay()
        barcodeScanner.close()
        textRecognizer.close()
        objectDetector.close()
        AtlasLiveSnifferStateStore.isCapturing = false
        if (activeInstance === this) {
            activeInstance = null
        }
        super.onDestroy()
    }

    private fun startLiveSniffer(intent: Intent) {
        AtlasLiveSnifferStateStore.resetError()

        if (!canDrawOverlays()) {
            AtlasLiveSnifferStateStore.fail("Display-over-other-apps permission is required.")
            stopSelf()
            return
        }

        val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, Int.MIN_VALUE)
        val resultData = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(EXTRA_RESULT_DATA, Intent::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(EXTRA_RESULT_DATA)
        }

        if (resultCode == Int.MIN_VALUE || resultData == null) {
            AtlasLiveSnifferStateStore.fail("Screen-capture permission data was missing.")
            stopSelf()
            return
        }

        startForeground(NOTIFICATION_ID, buildNotification())

        try {
            AtlasLiveSnifferStateStore.hudText = "ATLAS LIVE\nListening..."
            showOverlay()
            startProjection(resultCode, resultData)
            AtlasLiveSnifferStateStore.isCapturing = true
        } catch (error: Throwable) {
            AtlasLiveSnifferStateStore.fail(error.message ?: "Atlas Live Sniffer could not start.")
            stopSelfSafely()
        }
    }

    private fun startProjection(resultCode: Int, resultData: Intent) {
        releaseCapture()

        val projectionManager =
            getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val projection = projectionManager.getMediaProjection(resultCode, resultData)
            ?: throw IllegalStateException("Android did not return a MediaProjection session.")

        mediaProjection = projection
        projection.registerCallback(projectionCallback, Handler(mainLooper))

        val metrics = resources.displayMetrics
        val sourceWidth = metrics.widthPixels.coerceAtLeast(1)
        val sourceHeight = metrics.heightPixels.coerceAtLeast(1)
        val density = metrics.densityDpi.coerceAtLeast(1)

        // Capture is a mirror surface only; the source app remains full-screen.
        // 1280px preserves more small box-number/name text without asking Android
        // to resize or enter picture-in-picture.
        val longEdge = 1280
        val scale = if (sourceWidth >= sourceHeight) {
            longEdge.toDouble() / sourceWidth.toDouble()
        } else {
            longEdge.toDouble() / sourceHeight.toDouble()
        }.coerceAtMost(1.0)

        val width = (sourceWidth * scale).toInt().coerceAtLeast(1)
        val height = (sourceHeight * scale).toInt().coerceAtLeast(1)

        val thread = HandlerThread("AtlasLiveSnifferCapture").also { it.start() }
        captureThread = thread
        captureHandler = Handler(thread.looper)

        val reader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
        imageReader = reader
        reader.setOnImageAvailableListener({ source ->
            handleCapturedImage(source.acquireLatestImage(), width, height)
        }, captureHandler)

        virtualDisplay = projection.createVirtualDisplay(
            "AtlasLiveSniffer",
            width,
            height,
            density,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            reader.surface,
            null,
            captureHandler,
        )
    }

    private fun handleCapturedImage(image: Image?, width: Int, height: Int) {
        if (image == null) return

        // While the full-screen picker is active, the source app remains full-size
        // but recognition is intentionally paused until the user chooses a target.
        if (targetSelectionActive) {
            image.close()
            return
        }

        val now = SystemClock.elapsedRealtime()
        if (
            recognitionInFlight.get() ||
            now - lastRecognitionAtElapsedMs < MIN_RECOGNITION_INTERVAL_MS
        ) {
            image.close()
            return
        }

        lastRecognitionAtElapsedMs = now
        recognitionInFlight.set(true)

        val bitmap = try {
            imageToBitmap(image, width, height)
        } catch (_: Throwable) {
            null
        } finally {
            image.close()
        }

        if (bitmap == null) {
            recognitionInFlight.set(false)
            return
        }

        val capturedAtMicros = System.currentTimeMillis() * 1000L
        val sequence = frameSequence.incrementAndGet()
        val recognitionGeneration = targetGeneration

        if (singleTargetMode) {
            handleSingleTargetFrame(
                bitmap = bitmap,
                width = width,
                height = height,
                capturedAtMicros = capturedAtMicros,
                sequence = sequence,
                recognitionGeneration = recognitionGeneration,
            )
        } else {
            handleFullFrameRecognition(
                bitmap = bitmap,
                width = width,
                height = height,
                capturedAtMicros = capturedAtMicros,
                sequence = sequence,
                recognitionGeneration = recognitionGeneration,
            )
        }
    }

    private fun handleFullFrameRecognition(
        bitmap: Bitmap,
        width: Int,
        height: Int,
        capturedAtMicros: Long,
        sequence: Long,
        recognitionGeneration: Int,
    ) {
        val region = RecognitionRegion(
            bitmap = bitmap,
            sourceLeft = 0,
            sourceTop = 0,
            sourceWidth = width,
            sourceHeight = height,
        )
        runScopedRecognition(
            fullBitmap = bitmap,
            region = region,
            width = width,
            height = height,
            capturedAtMicros = capturedAtMicros,
            sequence = sequence,
            recognitionGeneration = recognitionGeneration,
            trackId = null,
            activeTracks = emptyList(),
            stateAtRecognition = "none",
            trackedBox = null,
        )
    }

    private fun handleSingleTargetFrame(
        bitmap: Bitmap,
        width: Int,
        height: Int,
        capturedAtMicros: Long,
        sequence: Long,
        recognitionGeneration: Int,
    ) {
        // TARGET_LOST is terminal for this selection generation. Do not let the
        // detector silently bind a different background object. The user must
        // tap the HUD and explicitly choose the Pop again.
        if (targetState == "lost") {
            emitTrackingOnlyFrame(
                capturedAtMicros,
                sequence,
                recognitionGeneration,
                width,
                height,
                emptyList(),
            )
            bitmap.recycle()
            recognitionInFlight.set(false)
            return
        }

        // The ROI used for this frame is always the last authoritative physical
        // location. On the very first frame after a tap it is a tight tap-centered
        // bootstrap box. The object detector then moves this box frame-to-frame.
        val bootstrapBounds = trackedBounds ?: buildInitialTargetBounds(
            pendingTargetX,
            pendingTargetY,
        )
        val recognitionBounds = bootstrapBounds ?: run {
            emitTrackingOnlyFrame(
                capturedAtMicros,
                sequence,
                recognitionGeneration,
                width,
                height,
                emptyList(),
            )
            bitmap.recycle()
            recognitionInFlight.set(false)
            return
        }

        val region = buildRecognitionRegionForBounds(
            source = bitmap,
            fullWidth = width,
            fullHeight = height,
            normalizedBounds = recognitionBounds,
        )

        val trackerBitmap = buildTrackerBitmap(bitmap)
        val trackerImage = InputImage.fromBitmap(trackerBitmap, 0)
        val detectorTask = objectDetector.process(trackerImage)
        val barcodeTask = barcodeScanner.process(InputImage.fromBitmap(region.bitmap, 0))
        val textTask = textRecognizer.process(InputImage.fromBitmap(region.bitmap, 0))

        Tasks.whenAllComplete(detectorTask, barcodeTask, textTask).addOnCompleteListener {
            if (recognitionGeneration != targetGeneration) {
                if (trackerBitmap !== bitmap && !trackerBitmap.isRecycled) trackerBitmap.recycle()
                region.recycleIfOwned(bitmap)
                bitmap.recycle()
                recognitionInFlight.set(false)
                return@addOnCompleteListener
            }

            val detected = if (detectorTask.isSuccessful) {
                detectorTask.result.orEmpty().map {
                    detectedObjectToTrack(it, trackerBitmap.width, trackerBitmap.height)
                }
            } else {
                emptyList()
            }

            val now = SystemClock.elapsedRealtime()
            updatePhysicalTarget(detected, now)
            val currentState = targetState
            val currentBounds = trackedBounds
            val currentTrackId = lockedTrackId

            if (currentBounds != null) {
                updateTargetReticle(currentBounds, currentState)
            }

            val bootstrapEvidenceAllowed =
                pendingTargetX != null &&
                    now - lastTargetSeenElapsedMs <= targetTrackingConfig.bootstrapEvidenceMs
            val allowEvidence = currentState == "locked" ||
                (currentState == "acquiring" &&
                    (pendingTargetX == null || bootstrapEvidenceAllowed))
            val barcodes = if (allowEvidence && barcodeTask.isSuccessful) {
                barcodeTask.result.orEmpty()
            } else {
                emptyList()
            }
            val recognized = if (allowEvidence && textTask.isSuccessful) textTask.result else null
            val recognizedText = recognized?.text?.trim().orEmpty()
            val textBlocks = if (allowEvidence) {
                recognized?.textBlocks.orEmpty().flatMap { block ->
                    block.lines.mapNotNull { line ->
                        val box = line.boundingBox ?: return@mapNotNull null
                        val text = line.text.trim()
                        if (text.isEmpty()) return@mapNotNull null
                        mapOf(
                            "text" to text,
                            "left" to region.fullX(box.left.toDouble(), width),
                            "top" to region.fullY(box.top.toDouble(), height),
                            "right" to region.fullX(box.right.toDouble(), width),
                            "bottom" to region.fullY(box.bottom.toDouble(), height),
                            "trackId" to currentTrackId,
                        )
                    }
                }
            } else {
                emptyList()
            }

            emitRecognitionFrame(
                capturedAtMicros = capturedAtMicros,
                sequence = sequence,
                selectionGeneration = recognitionGeneration,
                width = width,
                height = height,
                barcodes = barcodes,
                recognizedText = recognizedText,
                barcodeRegion = region,
                textBlocks = textBlocks,
                lockedTrackId = currentTrackId,
                targetState = currentState,
                trackedBox = currentBounds,
                activeTracks = detected,
            )

            if (trackerBitmap !== bitmap && !trackerBitmap.isRecycled) trackerBitmap.recycle()
            region.recycleIfOwned(bitmap)
            bitmap.recycle()
            recognitionInFlight.set(false)
        }
    }

    private fun runScopedRecognition(
        fullBitmap: Bitmap,
        region: RecognitionRegion,
        width: Int,
        height: Int,
        capturedAtMicros: Long,
        sequence: Long,
        recognitionGeneration: Int,
        trackId: Int?,
        activeTracks: List<NativeTrack>,
        stateAtRecognition: String,
        trackedBox: RectF?,
    ) {
        val inputImage = InputImage.fromBitmap(region.bitmap, 0)
        val barcodeTask = barcodeScanner.process(inputImage)
        val textTask = textRecognizer.process(inputImage)

        Tasks.whenAllComplete(barcodeTask, textTask).addOnCompleteListener {
            if (recognitionGeneration != targetGeneration) {
                region.recycleIfOwned(fullBitmap)
                fullBitmap.recycle()
                recognitionInFlight.set(false)
                return@addOnCompleteListener
            }
            val barcodes = if (barcodeTask.isSuccessful) barcodeTask.result.orEmpty() else emptyList()
            val recognized = if (textTask.isSuccessful) textTask.result else null
            emitRecognitionFrame(
                capturedAtMicros = capturedAtMicros,
                sequence = sequence,
                selectionGeneration = recognitionGeneration,
                width = width,
                height = height,
                barcodes = barcodes,
                recognizedText = recognized?.text?.trim().orEmpty(),
                barcodeRegion = region,
                textBlocks = recognized?.textBlocks.orEmpty().flatMap { block ->
                    block.lines.mapNotNull { line ->
                        val box = line.boundingBox ?: return@mapNotNull null
                        val text = line.text.trim()
                        if (text.isEmpty()) return@mapNotNull null
                        mapOf(
                            "text" to text,
                            "left" to region.fullX(box.left.toDouble(), width),
                            "top" to region.fullY(box.top.toDouble(), height),
                            "right" to region.fullX(box.right.toDouble(), width),
                            "bottom" to region.fullY(box.bottom.toDouble(), height),
                            "trackId" to trackId,
                        )
                    }
                },
                lockedTrackId = trackId,
                targetState = stateAtRecognition,
                trackedBox = trackedBox,
                activeTracks = activeTracks,
            )
            region.recycleIfOwned(fullBitmap)
            fullBitmap.recycle()
            recognitionInFlight.set(false)
        }
    }

    private fun emitTrackingOnlyFrame(
        capturedAtMicros: Long,
        sequence: Long,
        selectionGeneration: Int,
        width: Int,
        height: Int,
        activeTracks: List<NativeTrack>,
    ) {
        emitRecognitionFrame(
            capturedAtMicros = capturedAtMicros,
            sequence = sequence,
            selectionGeneration = selectionGeneration,
            width = width,
            height = height,
            barcodes = emptyList(),
            recognizedText = "",
            barcodeRegion = null,
            textBlocks = emptyList(),
            lockedTrackId = lockedTrackId,
            targetState = targetState,
            trackedBox = trackedBounds,
            activeTracks = activeTracks,
        )
    }

    private data class NativeTrack(
        val trackId: Int?,
        val bounds: RectF,
    )

    private fun detectedObjectToTrack(
        detectedObject: DetectedObject,
        trackerWidth: Int,
        trackerHeight: Int,
    ): NativeTrack {
        val box = detectedObject.boundingBox
        return NativeTrack(
            trackId = detectedObject.trackingId,
            bounds = RectF(
                box.left.toFloat() / trackerWidth.coerceAtLeast(1).toFloat(),
                box.top.toFloat() / trackerHeight.coerceAtLeast(1).toFloat(),
                box.right.toFloat() / trackerWidth.coerceAtLeast(1).toFloat(),
                box.bottom.toFloat() / trackerHeight.coerceAtLeast(1).toFloat(),
            ),
        )
    }

    private fun updatePhysicalTarget(detected: List<NativeTrack>, now: Long): NativeTrack? {
        if (targetState == "lost" && pendingTargetX == null && pendingTargetY == null) {
            return null
        }
        val tapX = pendingTargetX
        val tapY = pendingTargetY
        if (tapX != null && tapY != null) {
            val chosen = chooseTrackForTap(detected, tapX, tapY)
            if (chosen != null) {
                trackedBounds = chosen.bounds
                lockedTrackId = chosen.trackId
                pendingTargetX = null
                pendingTargetY = null
                lastTargetSeenElapsedMs = now
                targetState = if (chosen.trackId == null) "acquiring" else "locked"
                return chosen
            }
            targetState = "acquiring"
            return null
        }

        val priorBounds = trackedBounds ?: return null
        val exactTrackId = lockedTrackId
        val exact = if (exactTrackId == null) {
            null
        } else {
            detected.firstOrNull { it.trackId == exactTrackId }
        }
        if (exact != null) {
            trackedBounds = smoothBounds(priorBounds, exact.bounds)
            lastTargetSeenElapsedMs = now
            targetState = "locked"
            reacquireCandidateTrackId = null
            reacquireCandidateHits = 0
            return exact
        }

        val candidate = chooseReacquisitionTrack(detected, priorBounds)
        if (candidate != null) {
            val candidateId = candidate.trackId
            if (candidateId != null && candidateId != lockedTrackId) {
                if (reacquireCandidateTrackId == candidateId) {
                    reacquireCandidateHits += 1
                } else {
                    reacquireCandidateTrackId = candidateId
                    reacquireCandidateHits = 1
                }
                if (reacquireCandidateHits >= 2) {
                    trackedBounds = smoothBounds(priorBounds, candidate.bounds)
                    lockedTrackId = candidateId
                    lastTargetSeenElapsedMs = now
                    targetState = "locked"
                    reacquireCandidateTrackId = null
                    reacquireCandidateHits = 0
                    return candidate
                }
            } else if (lockedTrackId == null) {
                trackedBounds = smoothBounds(priorBounds, candidate.bounds)
                lastTargetSeenElapsedMs = now
                targetState = "acquiring"
                return candidate
            }
        } else {
            reacquireCandidateTrackId = null
            reacquireCandidateHits = 0
        }

        val elapsed = if (lastTargetSeenElapsedMs == 0L) 0L else now - lastTargetSeenElapsedMs
        targetState = when {
            elapsed <= targetTrackingConfig.coastMs -> "coasting"
            elapsed <= targetTrackingConfig.lostMs -> "reacquiring"
            else -> "lost"
        }
        if (targetState == "lost") {
            lockedTrackId = null
        }
        return null
    }

    private fun chooseTrackForTap(
        tracks: List<NativeTrack>,
        x: Double,
        y: Double,
    ): NativeTrack? {
        if (tracks.isEmpty()) return null
        val containing = tracks.filter { track ->
            x >= track.bounds.left && x <= track.bounds.right &&
                y >= track.bounds.top && y <= track.bounds.bottom
        }
        val bootstrap = buildInitialTargetBounds(x, y)
        val nearby = if (containing.isNotEmpty()) {
            containing
        } else if (bootstrap != null) {
            tracks.filter { track ->
                intersectionOverUnion(bootstrap, track.bounds) >= 0.05
            }
        } else {
            emptyList()
        }
        if (nearby.isEmpty()) return null
        return nearby.minByOrNull { track ->
            val cx = (track.bounds.left + track.bounds.right) / 2.0
            val cy = (track.bounds.top + track.bounds.bottom) / 2.0
            val dx = cx - x
            val dy = cy - y
            dx * dx + dy * dy
        }
    }

    private fun chooseReacquisitionTrack(
        tracks: List<NativeTrack>,
        prior: RectF,
    ): NativeTrack? {
        if (tracks.isEmpty()) return null
        val ranked = tracks.map { track ->
            val iou = intersectionOverUnion(prior, track.bounds)
            val priorCx = (prior.left + prior.right) / 2f
            val priorCy = (prior.top + prior.bottom) / 2f
            val cx = (track.bounds.left + track.bounds.right) / 2f
            val cy = (track.bounds.top + track.bounds.bottom) / 2f
            val dx = cx - priorCx
            val dy = cy - priorCy
            val distanceSq = dx * dx + dy * dy
            Triple(track, iou, distanceSq)
        }.sortedWith(compareByDescending<Triple<NativeTrack, Double, Float>> { it.second }
            .thenBy { it.third })
        val best = ranked.firstOrNull() ?: return null
        val priorArea = (prior.width() * prior.height()).coerceAtLeast(0.0001f)
        val bestArea = (best.first.bounds.width() * best.first.bounds.height())
            .coerceAtLeast(0.0001f)
        val areaRatio = bestArea / priorArea
        val sizeCompatible = areaRatio in 0.45f..2.20f
        val spatiallyCompatible =
            best.second >= targetTrackingConfig.reacquireMinIou ||
                best.third <= targetTrackingConfig.reacquireMaxCenterDistanceSquared
        return if (sizeCompatible && spatiallyCompatible) best.first else null
    }

    private fun intersectionOverUnion(a: RectF, b: RectF): Double {
        val left = maxOf(a.left, b.left)
        val top = maxOf(a.top, b.top)
        val right = minOf(a.right, b.right)
        val bottom = minOf(a.bottom, b.bottom)
        val intersection = maxOf(0f, right - left) * maxOf(0f, bottom - top)
        if (intersection <= 0f) return 0.0
        val aArea = maxOf(0f, a.width()) * maxOf(0f, a.height())
        val bArea = maxOf(0f, b.width()) * maxOf(0f, b.height())
        val union = aArea + bArea - intersection
        return if (union <= 0f) 0.0 else (intersection / union).toDouble()
    }

    private fun smoothBounds(previous: RectF, current: RectF): RectF {
        val alpha = 0.62f
        return RectF(
            previous.left + (current.left - previous.left) * alpha,
            previous.top + (current.top - previous.top) * alpha,
            previous.right + (current.right - previous.right) * alpha,
            previous.bottom + (current.bottom - previous.bottom) * alpha,
        )
    }

    private fun buildInitialTargetBounds(x: Double?, y: Double?): RectF? {
        if (x == null || y == null) return null
        val halfWidth = 0.22f
        val halfHeight = 0.24f
        return RectF(
            (x.toFloat() - halfWidth).coerceAtLeast(0f),
            (y.toFloat() - halfHeight).coerceAtLeast(0f),
            (x.toFloat() + halfWidth).coerceAtMost(1f),
            (y.toFloat() + halfHeight).coerceAtMost(1f),
        )
    }

    private fun buildTrackerBitmap(source: Bitmap): Bitmap {
        val longEdge = maxOf(source.width, source.height)
        if (longEdge <= TRACKER_LONG_EDGE) return source
        val scale = TRACKER_LONG_EDGE.toDouble() / longEdge.toDouble()
        return Bitmap.createScaledBitmap(
            source,
            (source.width * scale).toInt().coerceAtLeast(1),
            (source.height * scale).toInt().coerceAtLeast(1),
            true,
        )
    }

    private fun emitRecognitionFrame(
        capturedAtMicros: Long,
        sequence: Long,
        selectionGeneration: Int,
        width: Int,
        height: Int,
        barcodes: List<Barcode>,
        recognizedText: String,
        barcodeRegion: RecognitionRegion?,
        textBlocks: List<Map<String, Any?>>,
        lockedTrackId: Int?,
        targetState: String,
        trackedBox: RectF?,
        activeTracks: List<NativeTrack>,
    ) {
        AtlasLiveSnifferStateStore.emitFrame(
            mapOf(
                "type" to "frame",
                "capturedAtMicros" to capturedAtMicros,
                "nativeTimestampMs" to (capturedAtMicros / 1000L),
                "frameSequence" to sequence,
                "selectionGeneration" to selectionGeneration,
                "width" to width,
                "height" to height,
                "lockedTrackId" to lockedTrackId,
                "targetState" to targetState,
                "trackedBoundingBox" to trackedBox?.let(::rectToPayload),
                "activeTracks" to activeTracks.map { track ->
                    mapOf(
                        "trackId" to track.trackId,
                        "boundingBox" to rectToPayload(track.bounds),
                    )
                },
                "barcodes" to barcodes.mapNotNull { barcode ->
                    val region = barcodeRegion ?: return@mapNotNull null
                    barcodeToPayload(barcode, width, height, region, lockedTrackId)
                },
                "recognizedText" to recognizedText,
                "textBlocks" to textBlocks,
            ),
        )
    }

    private fun rectToPayload(rect: RectF): Map<String, Double> {
        return mapOf(
            "left" to rect.left.toDouble().coerceIn(0.0, 1.0),
            "top" to rect.top.toDouble().coerceIn(0.0, 1.0),
            "right" to rect.right.toDouble().coerceIn(0.0, 1.0),
            "bottom" to rect.bottom.toDouble().coerceIn(0.0, 1.0),
        )
    }

    private fun imageToBitmap(image: Image, width: Int, height: Int): Bitmap {
        val plane = image.planes.firstOrNull()
            ?: throw IllegalStateException("Screen-capture image contained no pixel plane.")
        val buffer = plane.buffer
        val pixelStride = plane.pixelStride.coerceAtLeast(1)
        val rowStride = plane.rowStride.coerceAtLeast(width * pixelStride)
        val rowPadding = rowStride - (pixelStride * width)
        val paddedWidth = width + (rowPadding / pixelStride)

        buffer.rewind()
        val padded = Bitmap.createBitmap(paddedWidth, height, Bitmap.Config.ARGB_8888)
        padded.copyPixelsFromBuffer(buffer)

        if (paddedWidth == width) {
            return padded
        }

        val cropped = Bitmap.createBitmap(padded, 0, 0, width, height)
        padded.recycle()
        return cropped
    }

    private fun barcodeToPayload(
        barcode: Barcode,
        width: Int,
        height: Int,
        region: RecognitionRegion,
        trackId: Int?,
    ): Map<String, Any?>? {
        val rawValue = barcode.rawValue?.trim().orEmpty()
        if (rawValue.isEmpty()) return null

        val box = barcode.boundingBox
        val left = region.fullX((box?.left ?: 0).toDouble(), width)
        val top = region.fullY((box?.top ?: 0).toDouble(), height)
        val right = region.fullX((box?.right ?: region.bitmap.width).toDouble(), width)
        val bottom = region.fullY((box?.bottom ?: region.bitmap.height).toDouble(), height)

        return mapOf(
            "rawValue" to rawValue,
            "format" to barcodeFormatName(barcode.format),
            "left" to minOf(left, right),
            "top" to minOf(top, bottom),
            "right" to maxOf(left, right),
            "bottom" to maxOf(top, bottom),
            "trackId" to trackId,
        )
    }

    private fun barcodeFormatName(format: Int): String {
        return when (format) {
            Barcode.FORMAT_UPC_A -> "UPC_A"
            Barcode.FORMAT_UPC_E -> "UPC_E"
            Barcode.FORMAT_EAN_8 -> "EAN_8"
            Barcode.FORMAT_EAN_13 -> "EAN_13"
            Barcode.FORMAT_QR_CODE -> "QR_CODE"
            else -> "UNKNOWN"
        }
    }

    private fun canDrawOverlays(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
    }

    private fun showOverlay() {
        removeOverlay()

        val manager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager = manager

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(22, 16, 22, 16)
            background = GradientDrawable().apply {
                cornerRadius = 28f
                setColor(Color.argb(225, 18, 22, 28))
                setStroke(2, Color.argb(210, 110, 168, 255))
            }
            elevation = 12f
        }

        val textView = TextView(this).apply {
            text = AtlasLiveSnifferStateStore.hudText
            setTextColor(Color.WHITE)
            textSize = 13f
            gravity = Gravity.START
        }
        container.addView(textView)

        val choiceRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            visibility = if (AtlasLiveSnifferStateStore.showScanChoices) {
                android.view.View.VISIBLE
            } else {
                android.view.View.GONE
            }
        }

        val featuredButton = Button(this).apply {
            text = "Scan One"
            textSize = 11f
            setOnClickListener {
                AtlasLiveSnifferStateStore.showScanChoices = false
                choiceRow.visibility = android.view.View.GONE
                beginTargetSelection()
            }
        }
        val allButton = Button(this).apply {
            text = "Scan All"
            textSize = 11f
            setOnClickListener {
                AtlasLiveSnifferStateStore.showScanChoices = false
                choiceRow.visibility = android.view.View.GONE
                clearTargetSelection()
                AtlasLiveSnifferStateStore.emitControl("allVisible", targetGeneration)
            }
        }
        choiceRow.addView(featuredButton)
        choiceRow.addView(allButton)
        container.addView(choiceRow)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.END
            x = 24
            y = 130
        }

        var startX = 0
        var startY = 0
        var touchX = 0f
        var touchY = 0f

        var moved = false
        textView.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    startX = params.x
                    startY = params.y
                    touchX = event.rawX
                    touchY = event.rawY
                    moved = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - touchX
                    val dy = event.rawY - touchY
                    if (dx * dx + dy * dy > 144f) moved = true
                    if (moved) {
                        params.x = startX - dx.toInt()
                        params.y = startY + dy.toInt()
                        manager.updateViewLayout(container, params)
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (!moved) {
                        beginTargetSelection()
                    }
                    true
                }
                MotionEvent.ACTION_CANCEL -> true
                else -> false
            }
        }

        manager.addView(container, params)
        overlayView = container
        overlayTextView = textView
        overlayChoiceRow = choiceRow
        AtlasLiveSnifferStateStore.isOverlayVisible = true
    }

    private fun beginTargetSelection() {
        targetGeneration++
        singleTargetMode = true
        targetSelectionActive = true
        pendingTargetX = null
        pendingTargetY = null
        lockedTrackId = null
        trackedBounds = null
        targetState = "awaitingSelection"
        lastTargetSeenElapsedMs = 0L
        reacquireCandidateTrackId = null
        reacquireCandidateHits = 0
        // Do not forcibly clear recognitionInFlight here. Any in-flight result is
        // invalidated by targetGeneration and must finish before a new ML Kit
        // request starts, preventing concurrent stale recognition races.
        AtlasLiveSnifferStateStore.showScanChoices = false
        overlayChoiceRow?.visibility = View.GONE
        updateOverlayState(
            "ATLAS LIVE\nTap the Pop you want to scan",
            showScanChoices = false,
            detectedCount = 0,
        )
        AtlasLiveSnifferStateStore.emitControl("targetSelectionStarted", targetGeneration)
        showTargetPicker()
    }

    private fun showTargetPicker() {
        removeTargetPicker()
        val manager = windowManager ?: return
        val picker = View(this).apply {
            // One-alpha background keeps this overlay touchable without visibly
            // dimming or resizing TikTok/Whatnot beneath it.
            setBackgroundColor(Color.argb(1, 0, 0, 0))
            setOnTouchListener { _, event ->
                if (event.action != MotionEvent.ACTION_UP) return@setOnTouchListener true
                val metrics = resources.displayMetrics
                val x = (event.rawX.toDouble() / metrics.widthPixels.coerceAtLeast(1).toDouble())
                    .coerceIn(0.0, 1.0)
                val y = (event.rawY.toDouble() / metrics.heightPixels.coerceAtLeast(1).toDouble())
                    .coerceIn(0.0, 1.0)
                targetGeneration++
                pendingTargetX = x
                pendingTargetY = y
                lockedTrackId = null
                trackedBounds = buildInitialTargetBounds(x, y)
                targetState = "acquiring"
                lastTargetSeenElapsedMs = SystemClock.elapsedRealtime()
                reacquireCandidateTrackId = null
                reacquireCandidateHits = 0
                targetSelectionActive = false
                removeTargetPicker()
                trackedBounds?.let { updateTargetReticle(it, targetState) }
                updateOverlayState(
                    "ATLAS LIVE\nTarget selected\nFinding physical track...",
                    showScanChoices = false,
                    detectedCount = 1,
                )
                AtlasLiveSnifferStateStore.emitTargetTap(x, y, targetGeneration)
                true
            }
        }
        val pickerParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }
        manager.addView(picker, pickerParams)
        targetPickerView = picker
    }

    private fun removeTargetPicker() {
        val picker = targetPickerView ?: return
        try {
            windowManager?.removeView(picker)
        } catch (_: Throwable) {
            // Picker may already be detached during service shutdown.
        }
        targetPickerView = null
    }

    private fun clearTargetSelection() {
        targetGeneration++
        targetSelectionActive = false
        singleTargetMode = false
        pendingTargetX = null
        pendingTargetY = null
        lockedTrackId = null
        trackedBounds = null
        targetState = "none"
        lastTargetSeenElapsedMs = 0L
        reacquireCandidateTrackId = null
        reacquireCandidateHits = 0
        removeTargetPicker()
        removeTargetReticle()
    }

    private data class RecognitionRegion(
        val bitmap: Bitmap,
        val sourceLeft: Int,
        val sourceTop: Int,
        val sourceWidth: Int,
        val sourceHeight: Int,
    ) {
        fun fullX(recognitionX: Double, fullWidth: Int): Double {
            val sourceX = sourceLeft.toDouble() +
                (recognitionX / bitmap.width.coerceAtLeast(1).toDouble()) * sourceWidth.toDouble()
            return (sourceX / fullWidth.coerceAtLeast(1).toDouble()).coerceIn(0.0, 1.0)
        }

        fun fullY(recognitionY: Double, fullHeight: Int): Double {
            val sourceY = sourceTop.toDouble() +
                (recognitionY / bitmap.height.coerceAtLeast(1).toDouble()) * sourceHeight.toDouble()
            return (sourceY / fullHeight.coerceAtLeast(1).toDouble()).coerceIn(0.0, 1.0)
        }

        fun recycleIfOwned(fullBitmap: Bitmap) {
            if (bitmap !== fullBitmap && !bitmap.isRecycled) bitmap.recycle()
        }
    }

    private fun buildRecognitionRegionForBounds(
        source: Bitmap,
        fullWidth: Int,
        fullHeight: Int,
        normalizedBounds: RectF,
    ): RecognitionRegion {
        val padded = RectF(
            (normalizedBounds.left - normalizedBounds.width() * targetTrackingConfig.roiPaddingFraction).coerceAtLeast(0f),
            (normalizedBounds.top - normalizedBounds.height() * targetTrackingConfig.roiPaddingFraction).coerceAtLeast(0f),
            (normalizedBounds.right + normalizedBounds.width() * targetTrackingConfig.roiPaddingFraction).coerceAtMost(1f),
            (normalizedBounds.bottom + normalizedBounds.height() * targetTrackingConfig.roiPaddingFraction).coerceAtMost(1f),
        )
        val left = (padded.left * fullWidth).toInt().coerceIn(0, fullWidth - 1)
        val top = (padded.top * fullHeight).toInt().coerceIn(0, fullHeight - 1)
        val right = (padded.right * fullWidth).toInt().coerceIn(left + 1, fullWidth)
        val bottom = (padded.bottom * fullHeight).toInt().coerceIn(top + 1, fullHeight)
        val cropWidth = right - left
        val cropHeight = bottom - top

        val crop = Bitmap.createBitmap(source, left, top, cropWidth, cropHeight)
        val scale = minOf(
            2.0,
            1500.0 / maxOf(cropWidth, cropHeight).coerceAtLeast(1).toDouble(),
        ).coerceAtLeast(1.0)
        val scaled = if (scale > 1.05) {
            Bitmap.createScaledBitmap(
                crop,
                (cropWidth * scale).toInt().coerceAtLeast(1),
                (cropHeight * scale).toInt().coerceAtLeast(1),
                true,
            ).also { crop.recycle() }
        } else {
            crop
        }
        return RecognitionRegion(
            bitmap = scaled,
            sourceLeft = left,
            sourceTop = top,
            sourceWidth = cropWidth,
            sourceHeight = cropHeight,
        )
    }

    private fun updateTargetReticle(bounds: RectF, state: String) {
        val manager = windowManager ?: return
        Handler(mainLooper).post {
            val metrics = resources.displayMetrics
            val width = ((bounds.right - bounds.left) * metrics.widthPixels).toInt().coerceAtLeast(24)
            val height = ((bounds.bottom - bounds.top) * metrics.heightPixels).toInt().coerceAtLeast(24)
            val x = (bounds.left * metrics.widthPixels).toInt()
            val y = (bounds.top * metrics.heightPixels).toInt()
            val view = targetReticleView ?: View(this).also { created ->
                targetReticleView = created
            }
            view.background = GradientDrawable().apply {
                setColor(Color.argb(1, 0, 0, 0))
                cornerRadius = 18f
                val strokeColor = when (state) {
                    "lost" -> Color.argb(235, 255, 92, 92)
                    "coasting", "reacquiring" -> Color.argb(235, 255, 190, 70)
                    else -> Color.argb(235, 88, 185, 255)
                }
                setStroke(5, strokeColor)
            }
            val params = WindowManager.LayoutParams(
                width,
                height,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE
                },
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                this.x = x
                this.y = y
            }
            try {
                if (view.parent == null) manager.addView(view, params) else manager.updateViewLayout(view, params)
            } catch (_: Throwable) {
                // Overlay can be detached while Android is stopping projection.
            }
        }
    }

    private fun removeTargetReticle() {
        val view = targetReticleView ?: return
        try {
            windowManager?.removeView(view)
        } catch (_: Throwable) {
            // Reticle may already be detached.
        }
        targetReticleView = null
    }

    private fun updateOverlayText(text: String) {
        updateOverlayState(
            text,
            AtlasLiveSnifferStateStore.showScanChoices,
            AtlasLiveSnifferStateStore.detectedCount,
        )
    }

    private fun updateOverlayState(
        text: String,
        showScanChoices: Boolean,
        detectedCount: Int,
    ) {
        AtlasLiveSnifferStateStore.hudText = text
        AtlasLiveSnifferStateStore.showScanChoices = showScanChoices
        AtlasLiveSnifferStateStore.detectedCount = detectedCount
        val view = overlayView ?: return
        Handler(mainLooper).post {
            if (overlayView === view) {
                overlayTextView?.text = if (showScanChoices && detectedCount > 1) {
                    "$text\n$detectedCount Pops visible — choose one or all:"
                } else {
                    text
                }
                overlayChoiceRow?.visibility = if (showScanChoices) {
                    android.view.View.VISIBLE
                } else {
                    android.view.View.GONE
                }
            }
        }
    }

    private fun removeOverlay() {
        removeTargetPicker()
        removeTargetReticle()
        val view = overlayView ?: return
        try {
            windowManager?.removeView(view)
        } catch (_: Throwable) {
            // The view may already have been detached by Android.
        }
        overlayView = null
        overlayTextView = null
        overlayChoiceRow = null
        AtlasLiveSnifferStateStore.showScanChoices = false
        AtlasLiveSnifferStateStore.detectedCount = 0
        AtlasLiveSnifferStateStore.isOverlayVisible = false
    }

    private fun releaseCapture() {
        virtualDisplay?.release()
        virtualDisplay = null

        imageReader?.setOnImageAvailableListener(null, null)
        imageReader?.close()
        imageReader = null

        mediaProjection?.unregisterCallback(projectionCallback)
        mediaProjection?.stop()
        mediaProjection = null

        captureHandler = null
        captureThread?.quitSafely()
        captureThread = null
        recognitionInFlight.set(false)
        clearTargetSelection()
    }

    private fun stopSelfSafely() {
        AtlasLiveSnifferStateStore.isCapturing = false
        releaseCapture()
        removeOverlay()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun buildNotification(): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setSmallIcon(android.R.drawable.ic_menu_view)
            .setContentTitle("Atlas Live Sniffer")
            .setContentText("Auction screen intelligence is active.")
            .setOngoing(true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            NOTIFICATION_CHANNEL_ID,
            "Atlas Live Sniffer",
            NotificationManager.IMPORTANCE_LOW,
        )
        channel.description = "Required while Atlas Live Sniffer is capturing the screen."
        manager.createNotificationChannel(channel)
    }
}
