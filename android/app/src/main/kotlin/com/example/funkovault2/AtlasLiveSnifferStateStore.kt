package com.example.funkovault2

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

object AtlasLiveSnifferStateStore {
    @Volatile var isCapturing: Boolean = false
    @Volatile var isOverlayVisible: Boolean = false
    @Volatile var lastError: String? = null
    @Volatile var hudText: String = "ATLAS LIVE\nListening..."
    @Volatile var showScanChoices: Boolean = false
    @Volatile var detectedCount: Int = 0

    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile
    private var eventSink: EventChannel.EventSink? = null

    fun resetError() {
        lastError = null
    }

    fun fail(message: String) {
        lastError = message
        isCapturing = false
        isOverlayVisible = false
        showScanChoices = false
        detectedCount = 0
    }

    fun setEventSink(sink: EventChannel.EventSink) {
        eventSink = sink
    }

    fun clearEventSink(sink: EventChannel.EventSink?) {
        if (sink == null || eventSink === sink) {
            eventSink = null
        }
    }

    fun emitFrame(frame: Map<String, Any?>) {
        emit(frame)
    }

    fun emitControl(action: String, selectionGeneration: Int? = null) {
        emit(
            mapOf(
                "type" to "control",
                "action" to action,
                "selectionGeneration" to selectionGeneration,
                "detectedCount" to detectedCount,
            ),
        )
    }

    fun emitTargetTap(x: Double, y: Double, selectionGeneration: Int) {
        emit(
            mapOf(
                "type" to "control",
                "action" to "targetTap",
                "x" to x.coerceIn(0.0, 1.0),
                "y" to y.coerceIn(0.0, 1.0),
                "selectionGeneration" to selectionGeneration,
                "detectedCount" to detectedCount,
            ),
        )
    }

    private fun emit(payload: Map<String, Any?>) {
        val sink = eventSink ?: return
        mainHandler.post {
            if (eventSink === sink) {
                sink.success(payload)
            }
        }
    }
}
