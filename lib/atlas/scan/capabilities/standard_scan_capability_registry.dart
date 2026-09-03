import '../../catalog/resolution/catalog_resolution_service.dart';
import '../../catalog/services/atlas_catalog_service.dart';
import '../engine/barcode_intelligence_engine.dart';
import '../engine/engine_context.dart';
import '../engine/identity_intelligence_engine.dart';
import '../engine/product_resolution_engine.dart';
import '../authenticity/atlas_authenticity_engine.dart';
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
        .register(_identityIntelligenceRegistration())
        .register(_productResolutionRegistration())
        .register(_authenticityRegistration())
        .build();
  }

  static ScanEngineRegistration _barcodeIntelligenceRegistration() {
    return ScanEngineRegistration(
      capabilityId: BarcodeIntelligenceEngine.capabilityId,
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

  static ScanEngineRegistration _identityIntelligenceRegistration() {
    return ScanEngineRegistration(
      capabilityId: IdentityIntelligenceEngine.capabilityId,
      engineId: IdentityIntelligenceEngine.id,
      displayName: 'Identity Intelligence',
      description:
          'Combines structured recognition evidence into '
          'collectible identity hypotheses.',
      category: EngineCapabilityCategory.identity,
      createEngine: () {
        return const IdentityIntelligenceEngine();
      },
      minimumAccessTier: AtlasAccessTier.guest,
      enabledByDefault: true,
      requiresOnline: false,
      tags: const <String>{
        'identity',
        'recognition',
        'ocr',
        'hypothesis',
        'offline',
        'resolution-input',
      },
      attributes: const <String, Object?>{
        'version': 1,
        'consumesContribution': 'OCRContribution',
        'producesContribution': 'IdentityContribution',
        'supportsBarcodeEvidence': true,
        'supportsOcrEvidence': true,
      },
    );
  }

  static ScanEngineRegistration _productResolutionRegistration() {
    return ScanEngineRegistration(
      capabilityId: ProductResolutionEngine.capabilityId,
      engineId: ProductResolutionEngine.id,
      displayName: 'Product Resolution',
      description:
          'Resolves collectible identity hypotheses against '
          'the shared Atlas product catalog.',
      category: EngineCapabilityCategory.resolution,
      createEngine: () {
        final CatalogResolutionService resolutionService =
            CatalogResolutionService(AtlasCatalogService.instance);

        return ProductResolutionEngine(resolutionService);
      },
      minimumAccessTier: AtlasAccessTier.guest,
      enabledByDefault: true,
      requiresOnline: false,
      tags: const <String>{
        'product',
        'resolution',
        'catalog',
        'identity',
        'matching',
        'offline',
      },
      attributes: const <String, Object?>{
        'version': 1,
        'consumesContribution': 'IdentityContribution',
        'producesContribution': 'ProductResolutionContribution',
        'usesSharedCatalogService': true,
        'supportsCandidateReview': true,
      },
    );
  }

  static ScanEngineRegistration _authenticityRegistration() {
    return ScanEngineRegistration(
      capabilityId: AtlasAuthenticityEngine.capabilityId,
      engineId: AtlasAuthenticityEngine.id,
      displayName: 'Authenticity Intelligence',
      description:
          'Evaluates visual inspection evidence conservatively and explains warning signals.',
      category: EngineCapabilityCategory.diagnostics,
      createEngine: () => const AtlasAuthenticityEngine(),
      minimumAccessTier: AtlasAccessTier.guest,
      enabledByDefault: true,
      requiresOnline: false,
      tags: const <String>{'authenticity', 'visual-inspection', 'offline'},
      attributes: const <String, Object?>{
        'version': 1,
        'consumesContribution': 'VisualInspectionContribution',
        'producesContribution': 'AuthenticityContribution',
      },
    );
  }
}
