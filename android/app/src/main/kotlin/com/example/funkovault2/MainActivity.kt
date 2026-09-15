package com.example.funkovault2

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "atlas/live_sniffer"
        private const val EVENT_CHANNEL = "atlas/live_sniffer/events"
        private const val REQUEST_SCREEN_CAPTURE = 6201
        private const val REQUEST_NOTIFICATIONS = 6202
    }

    private var pendingScreenCaptureResult: MethodChannel.Result? = null
    private var pendingNotificationResult: MethodChannel.Result? = null
    private var liveSnifferEventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(::handleLiveSnifferCall)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                        liveSnifferEventSink = events
                        AtlasLiveSnifferStateStore.setEventSink(events)
                    }

                    override fun onCancel(arguments: Any?) {
                        AtlasLiveSnifferStateStore.clearEventSink(liveSnifferEventSink)
                        liveSnifferEventSink = null
                    }
                },
            )
    }

    override fun onDestroy() {
        AtlasLiveSnifferStateStore.clearEventSink(liveSnifferEventSink)
        liveSnifferEventSink = null
        super.onDestroy()
    }

    private fun handleLiveSnifferCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> result.success(statusMap())
            "requestOverlayPermission" -> {
                if (canDrawOverlays()) {
                    result.success(true)
                    return
                }
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName"),
                )
                startActivity(intent)
                result.success(false)
            }
            "requestNotificationPermission" -> requestNotificationPermission(result)
            "start" -> requestScreenCapture(result)
            "stop" -> {
                val intent = Intent(this, AtlasLiveSnifferService::class.java).apply {
                    action = AtlasLiveSnifferService.ACTION_STOP
                }
                startService(intent)
                result.success(true)
            }
            "restartSelectedTarget" -> {
                result.success(AtlasLiveSnifferService.restartSelectedTargetIfActive())
            }
            "updateHud" -> {
                val text = call.argument<String>("text")?.trim().orEmpty()
                if (text.isEmpty()) {
                    result.error("invalid_hud", "HUD text cannot be empty.", null)
                    return
                }
                val showScanChoices = call.argument<Boolean>("showScanChoices") ?: false
                val detectedCount = call.argument<Int>("detectedCount") ?: 0
                AtlasLiveSnifferStateStore.hudText = text
                AtlasLiveSnifferStateStore.showScanChoices = showScanChoices
                AtlasLiveSnifferStateStore.detectedCount = detectedCount
                AtlasLiveSnifferService.updateHudIfActive(
                    text,
                    showScanChoices,
                    detectedCount,
                )
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun canDrawOverlays(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }
        if (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        if (pendingNotificationResult != null) {
            result.error("busy", "A notification permission request is already active.", null)
            return
        }
        pendingNotificationResult = result
        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            REQUEST_NOTIFICATIONS,
        )
    }

    private fun requestScreenCapture(result: MethodChannel.Result) {
        if (!canDrawOverlays()) {
            result.error(
                "overlay_permission_required",
                "Display-over-other-apps permission is required before Atlas LiveLens can start.",
                null,
            )
            return
        }
        if (pendingScreenCaptureResult != null) {
            result.error("busy", "A screen-capture request is already active.", null)
            return
        }

        AtlasLiveSnifferStateStore.resetError()
        val manager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        pendingScreenCaptureResult = result
        startActivityForResult(manager.createScreenCaptureIntent(), REQUEST_SCREEN_CAPTURE)
    }

    @Deprecated("Deprecated in Android; retained for FlutterActivity compatibility.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_SCREEN_CAPTURE) return

        val callback = pendingScreenCaptureResult
        pendingScreenCaptureResult = null

        if (resultCode != Activity.RESULT_OK || data == null) {
            callback?.success(false)
            return
        }

        val serviceIntent = Intent(this, AtlasLiveSnifferService::class.java).apply {
            action = AtlasLiveSnifferService.ACTION_START
            putExtra(AtlasLiveSnifferService.EXTRA_RESULT_CODE, resultCode)
            putExtra(AtlasLiveSnifferService.EXTRA_RESULT_DATA, data)
        }
        ContextCompat.startForegroundService(this, serviceIntent)
        callback?.success(true)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_NOTIFICATIONS) return

        val callback = pendingNotificationResult
        pendingNotificationResult = null
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        callback?.success(granted)
    }

    private fun statusMap(): Map<String, Any?> {
        val notificationGranted =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS,
                ) == PackageManager.PERMISSION_GRANTED

        return mapOf(
            "supported" to true,
            "overlayPermissionGranted" to canDrawOverlays(),
            "notificationPermissionGranted" to notificationGranted,
            "isCapturing" to AtlasLiveSnifferStateStore.isCapturing,
            "isOverlayVisible" to AtlasLiveSnifferStateStore.isOverlayVisible,
            "lastError" to AtlasLiveSnifferStateStore.lastError,
        )
    }
}
