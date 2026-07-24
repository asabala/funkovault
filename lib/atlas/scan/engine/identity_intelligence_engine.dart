import '../contributions/contribution_conflict_policy.dart';
import '../contributions/identity_contribution.dart';
import '../contributions/ocr_contribution.dart';
import '../identity/identity_hypothesis.dart';
import '../models/ocr_recognition_type.dart';
import '../models/scan_session.dart';
import '../recognition/recognition_evidence.dart';
import '../recognition/recognition_evidence_builder.dart';
import 'abstract_scan_engine.dart';
import 'engine_context.dart';
import 'engine_result.dart';
import 'engine_support.dart';

// Produces collectible identity hypotheses from recognition evidence.
//
// This initial implementation is intentionally conservative. It combines
// structured OCR evidence into an identity hypothesis without performing
// catalog lookups or canonical product resolution.
final class IdentityIntelligenceEngine
    extends AbstractScanEngine {
  const IdentityIntelligenceEngine();

  static const String id =
      'atlas.scan.identity-intelligence';

  static const String capabilityId =
      'atlas.capability.identity-intelligence';

  @override
  String get engineId {
    return id;
  }

  @override
  String get displayName {
    return 'Identity Intelligence';
  }

  @override
  Future<EngineResult> execute(
      ScanSession session,
      EngineContext context,
      ) async {
    final RecognitionEvidence evidence =
    RecognitionEvidenceBuilder.fromSession(
      session,
    );

    if (!evidence.hasRecognition) {
      return EngineResult.skipped(
        session: session,
        reason: 'No recognition evidence is available.',
        attributes: const <String, Object?>{
          'requirement': 'recognitionEvidence',
          'recognitionCount': 0,
        },
      );
    }

    final List<IdentityHypothesis> hypotheses =
    _buildHypotheses(
      evidence,
    );

    if (hypotheses.isEmpty) {
      return EngineResult.skipped(
        session: session,
        reason:
        'Recognition evidence did not produce a usable identity hypothesis.',
        attributes: <String, Object?>{
          'recognitionCount': evidence.recognitionCount,
          'barcodeCount': evidence.barcodes.length,
          'ocrCount': evidence.ocr.length,
        },
      );
    }

    final IdentityHypothesis primaryHypothesis =
        hypotheses.first;

    final IdentityContribution contribution =
    IdentityContribution(
      contributionId: _buildContributionId(
        session,
        primaryHypothesis,
      ),
      sourceEngineId: engineId,
      createdAt: session.startedAt,
      hypotheses: hypotheses,
      confidence: primaryHypothesis.confidence,
      attributes: <String, Object?>{
        'hypothesisCount': hypotheses.length,
        'hasAlternatives': hypotheses.length > 1,
        'recognitionCount': evidence.recognitionCount,
        'barcodeCount': evidence.barcodes.length,
        'ocrCount': evidence.ocr.length,
      },
    );

    final ScanSession updatedSession =
    session.addContributions(
      <IdentityContribution>[
        contribution,
      ],
      conflictPolicy:
      ContributionConflictPolicy.replaceExisting,
    );

    return EngineResult.success(
      session: updatedSession,
      attributes: <String, Object?>{
        'identityContributionCount': 1,
        'hypothesisCount': hypotheses.length,
        'primaryHypothesisId':
        primaryHypothesis.hypothesisId,
        'primaryDisplayName':
        primaryHypothesis.displayName,
        'primaryConfidence':
        primaryHypothesis.confidence,
      },
    );
  }

  List<IdentityHypothesis> _buildHypotheses(
      RecognitionEvidence evidence,
      ) {
    final OCRContribution? productLineEvidence =
    _firstOcrOfType(
      evidence,
      OCRRecognitionType.productLine,
    );

    final OCRContribution? brandEvidence =
    _firstOcrOfType(
      evidence,
      OCRRecognitionType.brand,
    );

    final OCRContribution? seriesEvidence =
    _firstOcrOfType(
      evidence,
      OCRRecognitionType.series,
    );

    final OCRContribution? characterEvidence =
    _firstOcrOfType(
      evidence,
      OCRRecognitionType.characterName,
    );

    final OCRContribution? titleEvidence =
    _firstOcrOfType(
      evidence,
      OCRRecognitionType.title,
    );

    final OCRContribution? productNumberEvidence =
    _firstOcrOfType(
      evidence,
      OCRRecognitionType.productNumber,
    );

    final OCRContribution? variantEvidence =
    _firstVariantEvidence(
      evidence,
    );

    final String? productLine =
    _normalizedValue(productLineEvidence);

    final String? brand =
    _normalizedValue(brandEvidence);

    final String? series =
    _normalizedValue(seriesEvidence);

    final String? characterName =
    _normalizedValue(characterEvidence);

    final String? title =
    _normalizedValue(titleEvidence);

    final String? productNumber =
    _normalizedValue(productNumberEvidence);

    final String? variantName =
    _normalizedValue(variantEvidence);

    final String? primaryName =
        characterName ?? title;

    if (primaryName == null &&
        productNumber == null &&
        series == null &&
        productLine == null) {
      return const <IdentityHypothesis>[];
    }

    final String displayName = _buildDisplayName(
      primaryName: primaryName,
      productNumber: productNumber,
      variantName: variantName,
      series: series,
      productLine: productLine,
    );

    if (displayName.isEmpty) {
      return const <IdentityHypothesis>[];
    }

    final List<OCRContribution> supportingEvidence =
    <OCRContribution>[
      ?productLineEvidence,
      ?brandEvidence,
      ?seriesEvidence,
      ?characterEvidence,
      ?titleEvidence,
      ?productNumberEvidence,
      ?variantEvidence,
    ];

    final double confidence =
    _calculateConfidence(
      supportingEvidence,
    );

    final String hypothesisId =
    EngineSupport.buildContributionId(
      namespace: 'atlas.identity.hypothesis',
      segments: <Object?>[
        productLine,
        brand,
        series,
        primaryName,
        productNumber,
        variantName,
      ],
    );

    return <IdentityHypothesis>[
      IdentityHypothesis(
        hypothesisId: hypothesisId,
        displayName: displayName,
        productLine: productLine,
        brand: brand,
        series: series,
        characterName: primaryName,
        productNumber: productNumber,
        variantName: variantName,
        confidence: confidence,
        supportingContributionIds:
        supportingEvidence
            .map(
              (OCRContribution contribution) =>
          contribution.contributionId,
        )
            .toList(growable: false),
        attributes: <String, Object?>{
          'hasCharacterName':
          characterName != null,
          'usedTitleAsPrimaryName':
          characterName == null &&
              title != null,
          'hasProductNumber':
          productNumber != null,
          'hasVariant':
          variantName != null,
          'supportingEvidenceCount':
          supportingEvidence.length,
        },
      ),
    ];
  }

  OCRContribution? _firstOcrOfType(
      RecognitionEvidence evidence,
      OCRRecognitionType recognitionType,
      ) {
    for (final OCRContribution contribution
    in evidence.ocr) {
      if (contribution.recognitionType ==
          recognitionType &&
          contribution.hasNormalizedText &&
          contribution.passedValidation) {
        return contribution;
      }
    }

    return null;
  }

  OCRContribution? _firstVariantEvidence(
      RecognitionEvidence evidence,
      ) {
    for (final OCRContribution contribution
    in evidence.variantText) {
      if (contribution.hasNormalizedText &&
          contribution.passedValidation) {
        return contribution;
      }
    }

    return null;
  }

  String? _normalizedValue(
      OCRContribution? contribution,
      ) {
    if (contribution == null) {
      return null;
    }

    final String normalized =
    contribution.normalizedText.trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  String _buildDisplayName({
    required String? primaryName,
    required String? productNumber,
    required String? variantName,
    required String? series,
    required String? productLine,
  }) {
    final List<String> parts = <String>[];

    if (primaryName != null) {
      parts.add(primaryName);
    } else if (series != null) {
      parts.add(series);
    } else if (productLine != null) {
      parts.add(productLine);
    }

    if (productNumber != null) {
      parts.add('#$productNumber');
    }

    if (variantName != null) {
      parts.add(variantName);
    }

    return parts.join(' ').trim();
  }

  double _calculateConfidence(
      List<OCRContribution> evidence,
      ) {
    final List<double> knownConfidenceValues =
    evidence
        .map(
          (OCRContribution contribution) =>
      contribution.confidence,
    )
        .whereType<double>()
        .toList(growable: false);

    if (knownConfidenceValues.isEmpty) {
      return 0.80;
    }

    final double total =
    knownConfidenceValues.fold<double>(
      0.0,
          (
          double currentTotal,
          double confidence,
          ) {
        return currentTotal +
            EngineSupport.normalizeConfidence(
              confidence,
            );
      },
    );

    return EngineSupport.normalizeConfidence(
      total / knownConfidenceValues.length,
      fallback: 0.80,
    );
  }

  String _buildContributionId(
      ScanSession session,
      IdentityHypothesis hypothesis,
      ) {
    return EngineSupport.buildContributionId(
      namespace: 'atlas.identity',
      segments: <Object?>[
        session.sessionId,
        hypothesis.hypothesisId,
      ],
    );
  }
}