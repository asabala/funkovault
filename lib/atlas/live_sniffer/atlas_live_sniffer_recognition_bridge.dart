import 'package:flutter/services.dart';

abstract interface class AtlasLiveSnifferRecognitionPlatform {
  Stream<Map<Object?, Object?>> get frames;

  Future<void> updateHud(
    String text, {
    bool showScanChoices = false,
    int detectedCount = 0,
  });
}

abstract interface class AtlasLiveSnifferRecognitionTurnoverPlatform {
  Future<bool> restartSelectedTarget();
}

final class AtlasLiveSnifferRecognitionBridge
    implements
        AtlasLiveSnifferRecognitionPlatform,
        AtlasLiveSnifferRecognitionTurnoverPlatform {
  const AtlasLiveSnifferRecognitionBridge({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ?? const MethodChannel('atlas/live_sniffer'),
       _eventChannel =
           eventChannel ?? const EventChannel('atlas/live_sniffer/events');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  @override
  Stream<Map<Object?, Object?>> get frames {
    return _eventChannel
        .receiveBroadcastStream()
        .where((Object? event) {
          return event is Map;
        })
        .map((Object? event) {
          return Map<Object?, Object?>.from(event! as Map);
        });
  }

  @override
  Future<bool> restartSelectedTarget() async {
    return await _methodChannel.invokeMethod<bool>('restartSelectedTarget') ??
        false;
  }

  @override
  Future<void> updateHud(
    String text, {
    bool showScanChoices = false,
    int detectedCount = 0,
  }) async {
    await _methodChannel.invokeMethod<bool>('updateHud', <String, Object?>{
      'text': text,
      'showScanChoices': showScanChoices,
      'detectedCount': detectedCount,
    });
  }
}
