import '../contributions/barcode_contribution.dart';
import '../contributions/contribution_conflict_policy.dart';
import '../models/scan_code.dart';
import '../models/scan_session.dart';
import 'abstract_scan_engine.dart';
import 'engine_context.dart';
import 'engine_result.dart';
import 'engine_support.dart';

// Evaluates detected barcode and QR evidence.
//
// This engine does not resolve a product identity. It validates existing
// ScanCode evidence and produces BarcodeContribution objects for downstream
// identity and product-resolution engines.
final class BarcodeIntelligenceEngine
    extends AbstractScanEngine {
  const BarcodeIntelligenceEngine();

  static const String id =
      'atlas.scan.barcode-intelligence';

  static const String capabilityId =
      'atlas.capability.barcode-intelligence';

  @override
  String get engineId {
    return id;
  }

  @override
  String get displayName {
    return 'Barcode Intelligence';
  }

  @override
  Future<EngineResult> execute(
      ScanSession session,
      EngineContext context,
      ) async {
    if (!session.hasDetectedCodes) {
      return EngineResult.skipped(
        session: session,
        reason: 'No barcode or QR code evidence was detected.',
        attributes: const <String, Object?>{
          'requirement': 'detectedCodes',
          'detectedCodeCount': 0,
        },
      );
    }

    final List<BarcodeContribution> contributions =
    <BarcodeContribution>[];

    int validCodeCount = 0;
    int usableProductBarcodeCount = 0;
    int qrCodeCount = 0;
    bool primaryAssigned = false;

    for (final ScanCode code in session.detectedCodes) {
      final _BarcodeValidation validation =
      _validate(code);

      if (validation.passed) {
        validCodeCount++;
      }

      if (code.isQrCode) {
        qrCodeCount++;
      }

      final bool isUsableProductBarcode =
          validation.passed &&
              code.isProductBarcode;

      if (isUsableProductBarcode) {
        usableProductBarcodeCount++;
      }

      final bool isPrimaryCandidate =
          !primaryAssigned &&
              isUsableProductBarcode;

      if (isPrimaryCandidate) {
        primaryAssigned = true;
      }

      contributions.add(
        BarcodeContribution(
          contributionId:
          _buildContributionId(code),
          sourceEngineId: engineId,
          createdAt: session.startedAt,
          code: code,
          isPrimaryCandidate:
          isPrimaryCandidate,
          passedValidation:
          validation.passed,
          validationMessage:
          validation.message,
          confidence: EngineSupport.normalizeConfidence(
            code.confidence,
          ),
          attributes: <String, Object?>{
            'format': code.format.name,
            'source': code.source.name,
            'isProductBarcode':
            code.isProductBarcode,
            'isQrCode': code.isQrCode,
            'characterCount':
            code.characterCount,
          },
        ),
      );
    }

    final ScanSession updatedSession =
    session.addContributions(
      contributions,
      conflictPolicy:
      ContributionConflictPolicy.replaceExisting,
    );

    final List<String> warnings = <String>[];

    if (validCodeCount == 0) {
      warnings.add(
        'No detected barcode or QR code passed validation.',
      );
    } else if (usableProductBarcodeCount == 0) {
      warnings.add(
        'No validated UPC or EAN product barcode was available.',
      );
    }

    return EngineResult.success(
      session: updatedSession,
      warnings: warnings,
      attributes: <String, Object?>{
        'detectedCodeCount':
        session.detectedCodes.length,
        'barcodeContributionCount':
        contributions.length,
        'validCodeCount':
        validCodeCount,
        'usableProductBarcodeCount':
        usableProductBarcodeCount,
        'qrCodeCount':
        qrCodeCount,
        'primaryCandidateAssigned':
        primaryAssigned,
      },
    );
  }

  _BarcodeValidation _validate(
      ScanCode code,
      ) {
    if (code.normalizedValue.trim().isEmpty) {
      return const _BarcodeValidation.failed(
        'The scanned code value is empty.',
      );
    }

    if (!code.isValid) {
      return const _BarcodeValidation.failed(
        'The scanner marked this code as invalid.',
      );
    }

    if (code.format == ScanCodeFormat.unknown) {
      return const _BarcodeValidation.failed(
        'The barcode format is unknown.',
      );
    }

    if (code.isProductBarcode &&
        !code.containsNumericValue) {
      return const _BarcodeValidation.failed(
        'UPC and EAN barcodes must contain only numbers.',
      );
    }

    if (code.isProductBarcode &&
        !_hasExpectedProductBarcodeLength(code)) {
      return _BarcodeValidation.failed(
        'The ${code.format.name} barcode has an unexpected length.',
      );
    }

    return const _BarcodeValidation.passed();
  }

  bool _hasExpectedProductBarcodeLength(
      ScanCode code,
      ) {
    switch (code.format) {
      case ScanCodeFormat.upcA:
        return code.characterCount == 12;

      case ScanCodeFormat.upcE:
        return code.characterCount == 8;

      case ScanCodeFormat.ean8:
        return code.characterCount == 8;

      case ScanCodeFormat.ean13:
        return code.characterCount == 13;

      case ScanCodeFormat.qrCode:
        return true;

      case ScanCodeFormat.unknown:
        return false;
    }
  }

  String _buildContributionId(
      ScanCode code,
      ) {
    return EngineSupport.buildContributionId(
      namespace: 'atlas.barcode',
      segments: <Object?>[
        code.format.name,
        code.normalizedValue,
      ],
    );
  }
}

// Internal validation result used only by BarcodeIntelligenceEngine.
final class _BarcodeValidation {
  const _BarcodeValidation._({
    required this.passed,
    this.message,
  });

  const _BarcodeValidation.passed()
      : this._(
    passed: true,
  );

  const _BarcodeValidation.failed(
      String message,
      ) : this._(
    passed: false,
    message: message,
  );

  final bool passed;

  final String? message;
}