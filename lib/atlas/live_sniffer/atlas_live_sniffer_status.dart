final class AtlasLiveSnifferStatus {
  const AtlasLiveSnifferStatus({
    required this.supported,
    required this.overlayPermissionGranted,
    required this.notificationPermissionGranted,
    required this.isCapturing,
    required this.isOverlayVisible,
    this.lastError,
  });

  const AtlasLiveSnifferStatus.unsupported()
    : supported = false,
      overlayPermissionGranted = false,
      notificationPermissionGranted = false,
      isCapturing = false,
      isOverlayVisible = false,
      lastError = null;

  factory AtlasLiveSnifferStatus.fromMap(Map<Object?, Object?> map) {
    return AtlasLiveSnifferStatus(
      supported: map['supported'] == true,
      overlayPermissionGranted: map['overlayPermissionGranted'] == true,
      notificationPermissionGranted:
          map['notificationPermissionGranted'] == true,
      isCapturing: map['isCapturing'] == true,
      isOverlayVisible: map['isOverlayVisible'] == true,
      lastError: _stringOrNull(map['lastError']),
    );
  }

  final bool supported;
  final bool overlayPermissionGranted;
  final bool notificationPermissionGranted;
  final bool isCapturing;
  final bool isOverlayVisible;
  final String? lastError;

  bool get isReadyToStart =>
      supported && overlayPermissionGranted && notificationPermissionGranted;

  static String? _stringOrNull(Object? value) {
    final String normalized = value?.toString().trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
