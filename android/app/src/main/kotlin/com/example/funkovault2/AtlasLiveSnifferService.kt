package com.example.funkovault2

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.WindowManager
import android.widget.TextView

class AtlasLiveSnifferService : Service() {
    companion object {
        const val ACTION_START = "com.example.funkovault2.action.START_LIVE_SNIFFER"
        const val ACTION_STOP = "com.example.funkovault2.action.STOP_LIVE_SNIFFER"
        const val EXTRA_RESULT_CODE = "result_code"
        const val EXTRA_RESULT_DATA = "result_data"

        private const val NOTIFICATION_CHANNEL_ID = "atlas_live_sniffer"
        private const val NOTIFICATION_ID = 6201
    }

    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private var captureThread: HandlerThread? = null
    private var captureHandler: Handler? = null

    private var windowManager: WindowManager? = null
    private var overlayView: TextView? = null

    private val projectionCallback = object : MediaProjection.Callback() {
        override fun onStop() {
            stopSelfSafely()
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelfSafely()
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
        AtlasLiveSnifferStateStore.isCapturing = false
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

        // 6C foundation intentionally samples into a reduced surface and drops the
        // frames. Recognition is connected in the next 6C checkpoint.
        val longEdge = 960
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
            source.acquireLatestImage()?.close()
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

    private fun canDrawOverlays(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
    }

    private fun showOverlay() {
        removeOverlay()

        val manager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager = manager

        val textView = TextView(this).apply {
            text = "ATLAS LIVE\nListening..."
            setTextColor(Color.WHITE)
            textSize = 13f
            gravity = Gravity.CENTER
            setPadding(28, 18, 28, 18)
            background = GradientDrawable().apply {
                cornerRadius = 28f
                setColor(Color.argb(225, 18, 22, 28))
                setStroke(2, Color.argb(210, 110, 168, 255))
            }
            elevation = 12f
        }

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
            y = 180
        }

        var startX = 0
        var startY = 0
        var touchX = 0f
        var touchY = 0f

        textView.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    startX = params.x
                    startY = params.y
                    touchX = event.rawX
                    touchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params.x = startX - (event.rawX - touchX).toInt()
                    params.y = startY + (event.rawY - touchY).toInt()
                    manager.updateViewLayout(textView, params)
                    true
                }
                else -> false
            }
        }

        manager.addView(textView, params)
        overlayView = textView
        AtlasLiveSnifferStateStore.isOverlayVisible = true
    }

    private fun removeOverlay() {
        val view = overlayView ?: return
        try {
            windowManager?.removeView(view)
        } catch (_: Throwable) {
            // The view may already have been detached by Android.
        }
        overlayView = null
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
            .setContentText("Screen intelligence is active.")
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
