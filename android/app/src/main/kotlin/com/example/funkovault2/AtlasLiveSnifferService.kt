package com.example.funkovault2

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
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
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.google.android.gms.tasks.Tasks
import java.util.concurrent.atomic.AtomicBoolean

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

    @Volatile private var targetSelectionActive: Boolean = false
    @Volatile private var targetX: Double? = null
    @Volatile private var targetY: Double? = null
    @Volatile private var targetGeneration: Int = 0

    private val recognitionInFlight = AtomicBoolean(false)
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

        // Scan One is intentionally paused until the user chooses a target.
        // MediaProjection keeps mirroring the full-size marketplace, but OCR
        // does not consume frames or keep guessing at background boxes.
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
        val recognitionGeneration = targetGeneration
        val recognitionRegion = buildRecognitionRegion(
            source = bitmap,
            fullWidth = width,
            fullHeight = height,
            focusX = targetX,
            focusY = targetY,
        )
        val inputImage = InputImage.fromBitmap(recognitionRegion.bitmap, 0)

        val barcodeTask = barcodeScanner.process(inputImage)
        val textTask = textRecognizer.process(inputImage)

        // Run barcode + OCR together. Auctions move quickly, and UPC is only a
        // bonus signal; OCR must not wait for the barcode pass to finish first.
        Tasks.whenAllComplete(barcodeTask, textTask).addOnCompleteListener {
            if (recognitionGeneration != targetGeneration) {
                recognitionRegion.recycleIfOwned(bitmap)
                bitmap.recycle()
                recognitionInFlight.set(false)
                return@addOnCompleteListener
            }
            val barcodes = if (barcodeTask.isSuccessful) {
                barcodeTask.result.orEmpty()
            } else {
                emptyList()
            }
            val recognized = if (textTask.isSuccessful) textTask.result else null
            val recognizedText = recognized?.text?.trim().orEmpty()

            emitRecognitionFrame(
                capturedAtMicros = capturedAtMicros,
                width = width,
                height = height,
                barcodes = barcodes,
                recognizedText = recognizedText,
                barcodeRegion = recognitionRegion,
                // Emit OCR at line granularity. When Scan One is locked,
                // line geometry is mapped from the cropped/upscaled target
                // image back into normalized full-screen coordinates.
                textBlocks = recognized?.textBlocks.orEmpty().flatMap { block ->
                    block.lines.mapNotNull { line ->
                        val box = line.boundingBox ?: return@mapNotNull null
                        val text = line.text.trim()
                        if (text.isEmpty()) return@mapNotNull null
                        mapOf(
                            "text" to text,
                            "left" to recognitionRegion.fullX(box.left.toDouble(), width),
                            "top" to recognitionRegion.fullY(box.top.toDouble(), height),
                            "right" to recognitionRegion.fullX(box.right.toDouble(), width),
                            "bottom" to recognitionRegion.fullY(box.bottom.toDouble(), height),
                        )
                    }
                },
            )
            recognitionRegion.recycleIfOwned(bitmap)
            bitmap.recycle()
            recognitionInFlight.set(false)
        }
    }

    private fun emitRecognitionFrame(
        capturedAtMicros: Long,
        width: Int,
        height: Int,
        barcodes: List<Barcode>,
        recognizedText: String,
        barcodeRegion: RecognitionRegion,
        textBlocks: List<Map<String, Any?>>,
    ) {
        AtlasLiveSnifferStateStore.emitFrame(
            mapOf(
                "type" to "frame",
                "capturedAtMicros" to capturedAtMicros,
                "width" to width,
                "height" to height,
                "barcodes" to barcodes.mapNotNull { barcode ->
                    barcodeToPayload(barcode, width, height, barcodeRegion)
                },
                "recognizedText" to recognizedText,
                "textBlocks" to textBlocks,
            ),
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
                AtlasLiveSnifferStateStore.emitControl("allVisible")
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
        targetSelectionActive = true
        targetX = null
        targetY = null
        recognitionInFlight.set(false)
        AtlasLiveSnifferStateStore.showScanChoices = false
        overlayChoiceRow?.visibility = View.GONE
        updateOverlayState(
            "ATLAS LIVE\nTap the Pop you want to scan",
            showScanChoices = false,
            detectedCount = 0,
        )
        AtlasLiveSnifferStateStore.emitControl("targetSelectionStarted")
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
                targetX = x
                targetY = y
                targetSelectionActive = false
                removeTargetPicker()
                updateOverlayState(
                    "ATLAS LIVE\nTarget locked\nScanning selected Pop...",
                    showScanChoices = false,
                    detectedCount = 1,
                )
                AtlasLiveSnifferStateStore.emitTargetTap(x, y)
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
        targetX = null
        targetY = null
        removeTargetPicker()
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

    private fun buildRecognitionRegion(
        source: Bitmap,
        fullWidth: Int,
        fullHeight: Int,
        focusX: Double?,
        focusY: Double?,
    ): RecognitionRegion {
        if (focusX == null || focusY == null) {
            return RecognitionRegion(
                bitmap = source,
                sourceLeft = 0,
                sourceTop = 0,
                sourceWidth = fullWidth,
                sourceHeight = fullHeight,
            )
        }

        // Tight enough to reject shelf/background boxes, large enough to keep
        // the Pop header number and bottom name strip inside one selected ROI.
        val cropWidth = (fullWidth * 0.62).toInt().coerceIn(1, fullWidth)
        val cropHeight = (fullHeight * 0.56).toInt().coerceIn(1, fullHeight)
        val centerX = (focusX * fullWidth).toInt()
        val centerY = (focusY * fullHeight).toInt()
        val left = (centerX - cropWidth / 2).coerceIn(0, fullWidth - cropWidth)
        val top = (centerY - cropHeight / 2).coerceIn(0, fullHeight - cropHeight)

        val crop = Bitmap.createBitmap(source, left, top, cropWidth, cropHeight)
        val scale = minOf(
            2.0,
            1500.0 / maxOf(cropWidth, cropHeight).coerceAtLeast(1).toDouble(),
        ).coerceAtLeast(1.0)
        val scaled = if (scale > 1.05) {
            val scaledWidth = (cropWidth * scale).toInt().coerceAtLeast(1)
            val scaledHeight = (cropHeight * scale).toInt().coerceAtLeast(1)
            Bitmap.createScaledBitmap(crop, scaledWidth, scaledHeight, true).also {
                crop.recycle()
            }
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
