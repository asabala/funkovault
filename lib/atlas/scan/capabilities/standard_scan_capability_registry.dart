import '../engine/barcode_intelligence_engine.dart';
import '../engine/engine_context.dart';
import 'engine_capability_category.dart';
import 'scan_capability_registry.dart';
import 'scan_engine_registration.dart';

// Creates the standard set of Atlas scan capabilities.
//
// This is the central composition point for built-in intelligence engines.
// Future OCR, vision, identity, market, vault, and briefing capabilities
// should be registered here without changing ScanPipeline.
abstract final class StandardScanCapabilityRegistry {
  static ScanCapabilityRegistry create() {
    return ScanCapabilityRegistryBuilder()
        .register(_barcodeIntelligenceRegistration())
        .build();
  }

  static ScanEngineRegistration
  _barcodeIntelligenceRegistration() {
    return ScanEngineRegistration(
      capabilityId:
      BarcodeIntelligenceEngine.capabilityId,
      engineId: BarcodeIntelligenceEngine.id,
      displayName: 'Barcode Intelligence',
      description:
      'Validates barcode and QR evidence and converts it into '
          'structured Atlas intelligence contributions.',
      category: EngineCapabilityCategory.recognition,
      createEngine: () {
        return const BarcodeIntelligenceEngine();
      },
      minimumAccessTier: AtlasAccessTier.guest,
      enabledByDefault: true,
      requiresOnline: false,
      tags: const <String>{
        'barcode',
        'qr',
        'evidence',
        'offline',
        'identity-input',
      },
      attributes: const <String, Object?>{
        'version': 1,
        'producesContribution': 'BarcodeContribution',
        'supportsProductBarcodes': true,
        'supportsQrCodes': true,
      },
    );
  }
}