import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'atlas_live_sniffer_bridge.dart';
import 'atlas_live_sniffer_status.dart';

final class AtlasLiveSnifferController extends ChangeNotifier {
  AtlasLiveSnifferController({AtlasLiveSnifferPlatform? platform})
    : _platform = platform ?? const AtlasLiveSnifferBridge();

  final AtlasLiveSnifferPlatform _platform;

  AtlasLiveSnifferStatus _status = const AtlasLiveSnifferStatus.unsupported();
  bool _busy = false;
  String? _message;

  AtlasLiveSnifferStatus get status => _status;
  bool get busy => _busy;
  String? get message => _message;

  Future<void> refresh() async {
    await _run(() async {
      _status = await _platform.getStatus();
    });
  }

  Future<void> requestOverlayPermission() async {
    await _run(() async {
      final bool alreadyGranted = await _platform.requestOverlayPermission();
      _status = await _platform.getStatus();
      _message = alreadyGranted || _status.overlayPermissionGranted
          ? 'Display-over-other-apps permission is ready.'
          : 'Android opened the overlay permission screen. Grant permission, '
                'then return to Atlas.';
    });
  }

  Future<void> requestNotificationPermission() async {
    await _run(() async {
      final bool granted = await _platform.requestNotificationPermission();
      _status = await _platform.getStatus();
      _message = granted || _status.notificationPermissionGranted
          ? 'Notification permission is ready.'
          : 'Notification permission was not granted.';
    });
  }

  Future<void> start() async {
    await _run(() async {
      _status = await _platform.getStatus();

      if (!_status.supported) {
        _message = 'Live Sniffer is currently available on Android only.';
        return;
      }

      if (!_status.overlayPermissionGranted) {
        _message =
            'Grant Display over other apps before starting Live Sniffer.';
        return;
      }

      if (!_status.notificationPermissionGranted) {
        _message =
            'Grant notification permission before starting Live Sniffer.';
        return;
      }

      final bool started = await _platform.start();
      _status = await _platform.getStatus();
      _message = started
          ? 'Atlas Live Sniffer started. You can switch to another app.'
          : 'Screen capture was cancelled.';
    });
  }

  Future<void> stop() async {
    await _run(() async {
      await _platform.stop();
      _status = await _platform.getStatus();
      _message = 'Atlas Live Sniffer stopped.';
    });
  }

  void clearMessage() {
    if (_message == null) return;
    _message = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;

    _busy = true;
    _message = null;
    notifyListeners();

    try {
      await action();
    } on PlatformException catch (error) {
      _message = error.message ?? 'Android could not complete that request.';
      _status = await _safeStatus();
    } catch (error) {
      _message = error.toString();
      _status = await _safeStatus();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<AtlasLiveSnifferStatus> _safeStatus() async {
    try {
      return await _platform.getStatus();
    } catch (_) {
      return _status;
    }
  }
}
