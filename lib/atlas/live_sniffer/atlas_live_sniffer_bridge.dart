import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'atlas_live_sniffer_status.dart';

abstract interface class AtlasLiveSnifferPlatform {
  Future<AtlasLiveSnifferStatus> getStatus();

  Future<bool> requestOverlayPermission();

  Future<bool> requestNotificationPermission();

  Future<bool> start();

  Future<bool> stop();
}

final class AtlasLiveSnifferBridge implements AtlasLiveSnifferPlatform {
  const AtlasLiveSnifferBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('atlas/live_sniffer');

  final MethodChannel _channel;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<AtlasLiveSnifferStatus> getStatus() async {
    if (!_isAndroid) {
      return const AtlasLiveSnifferStatus.unsupported();
    }

    final Map<Object?, Object?>? result = await _channel
        .invokeMapMethod<Object?, Object?>('getStatus');

    if (result == null) {
      return const AtlasLiveSnifferStatus.unsupported();
    }

    return AtlasLiveSnifferStatus.fromMap(result);
  }

  @override
  Future<bool> requestOverlayPermission() async {
    if (!_isAndroid) return false;
    return await _channel.invokeMethod<bool>('requestOverlayPermission') ??
        false;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    if (!_isAndroid) return false;
    return await _channel.invokeMethod<bool>('requestNotificationPermission') ??
        false;
  }

  @override
  Future<bool> start() async {
    if (!_isAndroid) return false;
    return await _channel.invokeMethod<bool>('start') ?? false;
  }

  @override
  Future<bool> stop() async {
    if (!_isAndroid) return false;
    return await _channel.invokeMethod<bool>('stop') ?? false;
  }
}
