package com.example.funkovault2

object AtlasLiveSnifferStateStore {
    @Volatile var isCapturing: Boolean = false
    @Volatile var isOverlayVisible: Boolean = false
    @Volatile var lastError: String? = null

    fun resetError() {
        lastError = null
    }

    fun fail(message: String) {
        lastError = message
        isCapturing = false
        isOverlayVisible = false
    }
}
