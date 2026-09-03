import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/live_sniffer/atlas_live_sniffer_bridge.dart';
import 'package:funkovault2/atlas/live_sniffer/atlas_live_sniffer_controller.dart';
import 'package:funkovault2/atlas/live_sniffer/atlas_live_sniffer_status.dart';

void main() {
  test('start is blocked until required permissions are ready', () async {
    final platform = _FakePlatform(
      status: const AtlasLiveSnifferStatus(
        supported: true,
        overlayPermissionGranted: false,
        notificationPermissionGranted: true,
        isCapturing: false,
        isOverlayVisible: false,
      ),
    );
    final controller = AtlasLiveSnifferController(platform: platform);

    await controller.start();

    expect(platform.startCalls, 0);
    expect(controller.message, contains('Display over other apps'));
  });

  test('start delegates after permissions are ready', () async {
    final platform = _FakePlatform(
      status: const AtlasLiveSnifferStatus(
        supported: true,
        overlayPermissionGranted: true,
        notificationPermissionGranted: true,
        isCapturing: false,
        isOverlayVisible: false,
      ),
    );
    final controller = AtlasLiveSnifferController(platform: platform);

    await controller.start();

    expect(platform.startCalls, 1);
    expect(controller.message, contains('started'));
  });
}

final class _FakePlatform implements AtlasLiveSnifferPlatform {
  _FakePlatform({required this.status});

  AtlasLiveSnifferStatus status;
  int startCalls = 0;

  @override
  Future<AtlasLiveSnifferStatus> getStatus() async => status;

  @override
  Future<bool> requestNotificationPermission() async {
    status = AtlasLiveSnifferStatus(
      supported: status.supported,
      overlayPermissionGranted: status.overlayPermissionGranted,
      notificationPermissionGranted: true,
      isCapturing: status.isCapturing,
      isOverlayVisible: status.isOverlayVisible,
      lastError: status.lastError,
    );
    return true;
  }

  @override
  Future<bool> requestOverlayPermission() async {
    status = AtlasLiveSnifferStatus(
      supported: status.supported,
      overlayPermissionGranted: true,
      notificationPermissionGranted: status.notificationPermissionGranted,
      isCapturing: status.isCapturing,
      isOverlayVisible: status.isOverlayVisible,
      lastError: status.lastError,
    );
    return true;
  }

  @override
  Future<bool> start() async {
    startCalls++;
    status = AtlasLiveSnifferStatus(
      supported: status.supported,
      overlayPermissionGranted: status.overlayPermissionGranted,
      notificationPermissionGranted: status.notificationPermissionGranted,
      isCapturing: true,
      isOverlayVisible: true,
      lastError: null,
    );
    return true;
  }

  @override
  Future<bool> stop() async {
    status = AtlasLiveSnifferStatus(
      supported: status.supported,
      overlayPermissionGranted: status.overlayPermissionGranted,
      notificationPermissionGranted: status.notificationPermissionGranted,
      isCapturing: false,
      isOverlayVisible: false,
      lastError: null,
    );
    return true;
  }
}
