import '../../intelligence/identity/atlas_identity_analysis_engine.dart';
import '../models/scan_session.dart';
import 'atlas_production_stamp_parser.dart';
import 'models/atlas_authenticity_assessment.dart';
import 'models/atlas_authenticity_evidence.dart';
import 'models/atlas_authenticity_signal.dart';
import 'models/atlas_inspection_reference.dart';
import 'models/atlas_production_stamp.dart';
import 'models/atlas_visual_inspection.dart';

abstract final class AtlasAuthenticityRules {
  static const double minimumEvidenceConfidence = 0.40;
  static const double categoryConcernCap = 0.35;
  static const double reviewThreshold = 0.10;
  static const double significantThreshold = 0.35;
  static const double strongIndicatorThreshold = 0.65;

  static AtlasAuthenticityAssessment evaluate({
    required ScanSession session,
    required AtlasVisualInspection inspection,
  }) {
    final List<AtlasAuthenticitySignal> displaySignals =
        <AtlasAuthenticitySignal>[];
    final List<AtlasEvaluatedAuthenticitySignal> evaluatedSignals =
        <AtlasEvaluatedAuthenticitySignal>[];
    final List<String> audit = <String>[];

    final AtlasInspectionReferenceCriteria reference =
        inspection.referenceCriteria ?? _fallbackReference(session);

    _evaluateLegacyInspection(
      session: session,
      inspection: inspection,
      reference: reference,
      displaySignals: displaySignals,
      evaluatedSignals: evaluatedSignals,
    );

    _evaluateStructuredObservations(
      inspection: inspection,
      reference: reference,
      evaluatedSignals: evaluatedSignals,
      displaySignals: displaySignals,
    );

    final double evidenceConfidence = inspection.resolvedEvidenceConfidence;
    final double inspectionCoverage =
        inspection.inspectedAreas.length / AtlasInspectionArea.values.length;
    final List<AtlasInspectionArea> uninspectedAreas = AtlasInspectionArea
        .values
        .where(
          (AtlasInspectionArea area) =>
              !inspection.inspectedAreas.contains(area),
        )
        .toList(growable: false);

    if (!inspection.hasAnyLegacyEvidence &&
        !inspection.hasStructuredObservations) {
      audit.add(
        'No inspection evidence was supplied. Uninspected areas do not count as discrepancies.',
      );
      return _assessment(
        concernLevel: AtlasAuthenticityConcernLevel.insufficientData,
        evidenceConfidence: 0.0,
        referenceCoverage: reference.completenessScore,
        inspectionCoverage: 0.0,
        aggregatedConcernScore: 0.0,
        summary:
            'There is not enough evidence to form a useful authenticity assessment.',
        displaySignals: displaySignals,
        evaluatedSignals: evaluatedSignals,
        uninspectedAreas: uninspectedAreas,
        audit: audit,
        productionStamp: inspection.hasProductionEvidence
            ? AtlasProductionStampParser.parse(inspection.productionStampText)
            : null,
      );
    }

    if (evidenceConfidence < minimumEvidenceConfidence) {
      audit.add(
        'Evidence confidence is below the assessment threshold. Low-quality evidence is not treated as counterfeit evidence.',
      );
      return _assessment(
        concernLevel: AtlasAuthenticityConcernLevel.insufficientData,
        evidenceConfidence: evidenceConfidence,
        referenceCoverage: reference.completenessScore,
        inspectionCoverage: inspectionCoverage,
        aggregatedConcernScore: 0.0,
        summary:
            'The available images or observations are not clear enough for a reliable authenticity comparison.',
        displaySignals: displaySignals,
        evaluatedSignals: evaluatedSignals,
        uninspectedAreas: uninspectedAreas,
        audit: audit,
        productionStamp: inspection.hasProductionEvidence
            ? AtlasProductionStampParser.parse(inspection.productionStampText)
            : null,
      );
    }

    if (!reference.canSupportConcernAssessment) {
      audit.add(
        'Reference coverage is insufficient for concern scoring. Incomplete reference data is not treated as counterfeit evidence.',
      );
      return _assessment(
        concernLevel: AtlasAuthenticityConcernLevel.insufficientData,
        evidenceConfidence: evidenceConfidence,
        referenceCoverage: reference.completenessScore,
        inspectionCoverage: inspectionCoverage,
        aggregatedConcernScore: 0.0,
        summary:
            'Atlas recorded the inspection evidence, but the reference data is not complete enough for a reliable authenticity comparison.',
        displaySignals: displaySignals,
        evaluatedSignals: evaluatedSignals,
        uninspectedAreas: uninspectedAreas,
        audit: audit,
        productionStamp: inspection.hasProductionEvidence
            ? AtlasProductionStampParser.parse(inspection.productionStampText)
            : null,
      );
    }

    final _ConcernAggregation aggregation = _aggregateConcern(
      evaluatedSignals,
      audit,
    );

    final AtlasAuthenticityConcernLevel concernLevel;
    if (aggregation.criticalCategories >= 2 &&
        aggregation.score >= strongIndicatorThreshold) {
      concernLevel = AtlasAuthenticityConcernLevel.strongCounterfeitIndicators;
      audit.add(
        'Strong indicators require critical contradictions in at least two independent evidence categories.',
      );
    } else if (aggregation.score >= significantThreshold) {
      concernLevel = AtlasAuthenticityConcernLevel.significantInconsistencies;
    } else if (aggregation.score > reviewThreshold) {
      concernLevel = AtlasAuthenticityConcernLevel.reviewRecommended;
    } else {
      concernLevel = AtlasAuthenticityConcernLevel.noObviousConcerns;
    }

    return _assessment(
      concernLevel: concernLevel,
      evidenceConfidence: evidenceConfidence,
      referenceCoverage: reference.completenessScore,
      inspectionCoverage: inspectionCoverage,
      aggregatedConcernScore: aggregation.score,
      summary: _summaryForConcern(concernLevel),
      displaySignals: displaySignals,
      evaluatedSignals: evaluatedSignals,
      uninspectedAreas: uninspectedAreas,
      audit: audit,
      productionStamp: inspection.hasProductionEvidence
          ? AtlasProductionStampParser.parse(inspection.productionStampText)
          : null,
    );
  }

  static void _evaluateLegacyInspection({
    required ScanSession session,
    required AtlasVisualInspection inspection,
    required AtlasInspectionReferenceCriteria reference,
    required List<AtlasAuthenticitySignal> displaySignals,
    required List<AtlasEvaluatedAuthenticitySignal> evaluatedSignals,
  }) {
    final bool hasStructuredVariantSticker = inspection.observations.any(
      (AtlasVisualEvidenceObservation observation) =>
          observation.category == AtlasEvidenceCategory.variantSticker,
    );
    final bool hasStructuredProductionStamp = inspection.observations.any(
      (AtlasVisualEvidenceObservation observation) =>
          observation.category == AtlasEvidenceCategory.productionStamp,
    );
    final bool hasStructuredMacroPackaging = inspection.observations.any(
      (AtlasVisualEvidenceObservation observation) =>
          observation.category == AtlasEvidenceCategory.macroPackaging,
    );
    final bool hasStructuredAutographCoa = inspection.observations.any(
      (AtlasVisualEvidenceObservation observation) =>
          observation.category == AtlasEvidenceCategory.autographCoa,
    );

    if (inspection.hasStickerEvidence && !hasStructuredVariantSticker) {
      final analysis = AtlasIdentityAnalysisEngine.create().analyze(
        inspection.stickerText,
      );
      final Set<String> detected = <String>{
        ...analysis.stickerResult.stickers.map((value) => value.displayName),
        ...analysis.variantResult.variants.map((value) => value.displayName),
      };

      if (detected.isEmpty) {
        displaySignals.add(
          const AtlasAuthenticitySignal(
            id: 'sticker-unclassified',
            title: 'Sticker needs confirmation',
            message: 'Atlas could not classify the observed sticker text.',
            level: AtlasAuthenticitySignalLevel.caution,
            weight: -5,
          ),
        );
        evaluatedSignals.add(
          AtlasEvaluatedAuthenticitySignal(
            id: 'sticker-unclassified',
            area: AtlasInspectionArea.windowSticker,
            category: AtlasEvidenceCategory.variantSticker,
            severity: AtlasSignalSeverity.advisory,
            disposition: AtlasSignalDisposition.observational,
            confidence: inspection.resolvedEvidenceConfidence,
            baseWeight: 0.0,
            rationale:
                'The sticker text could not be classified. Unknown is not a discrepancy.',
          ),
        );
      } else {
        displaySignals.add(
          AtlasAuthenticitySignal(
            id: 'sticker-classified',
            title: 'Sticker evidence classified',
            message: detected.join(' • '),
            level: AtlasAuthenticitySignalLevel.support,
            weight: 10,
          ),
        );
      }

      final String expectedVariant =
          session.resolvedProduct?.variantName?.trim() ?? '';
      if (expectedVariant.isNotEmpty &&
          !inspection.stickerText.toLowerCase().contains(
            expectedVariant.toLowerCase(),
          )) {
        displaySignals.add(
          const AtlasAuthenticitySignal(
            id: 'sticker-variant-conflict',
            title: 'Sticker and catalog variant differ',
            message:
                'Confirm the exact sticker and physical variant before saving.',
            level: AtlasAuthenticitySignalLevel.warning,
            weight: -25,
          ),
        );
        evaluatedSignals.add(
          AtlasEvaluatedAuthenticitySignal(
            id: 'sticker-variant-conflict',
            area: AtlasInspectionArea.windowSticker,
            category: AtlasEvidenceCategory.variantSticker,
            severity: AtlasSignalSeverity.moderate,
            disposition: AtlasSignalDisposition.discrepancy,
            confidence: inspection.resolvedEvidenceConfidence,
            baseWeight: 0.25,
            rationale:
                'Observed sticker text does not contain the resolved catalog variant.',
          ),
        );
      }

      if (reference.legitimateVariantTypes.isNotEmpty &&
          !reference.legitimateVariantTypes.any(
            (String variant) => inspection.stickerText.toLowerCase().contains(
              variant.toLowerCase(),
            ),
          )) {
        evaluatedSignals.add(
          AtlasEvaluatedAuthenticitySignal(
            id: 'sticker-reference-mismatch',
            area: AtlasInspectionArea.windowSticker,
            category: AtlasEvidenceCategory.variantSticker,
            severity: AtlasSignalSeverity.moderate,
            disposition: AtlasSignalDisposition.discrepancy,
            confidence: inspection.resolvedEvidenceConfidence,
            baseWeight: 0.28,
            rationale:
                'Observed sticker text does not match a recorded legitimate variant family.',
          ),
        );
      }
    }

    if (inspection.hasProductionEvidence && !hasStructuredProductionStamp) {
      final stamp = AtlasProductionStampParser.parse(
        inspection.productionStampText,
      );
      if (stamp.isValid) {
        displaySignals.add(
          AtlasAuthenticitySignal(
            id: 'production-stamp',
            title: '${stamp.factoryCode} production stamp recognized',
            message: stamp.itemBatch ?? inspection.productionStampText,
            level: AtlasAuthenticitySignalLevel.support,
            weight: 10,
          ),
        );
      } else {
        displaySignals.add(
          const AtlasAuthenticitySignal(
            id: 'production-stamp-unreadable',
            title: 'Production stamp needs review',
            message:
                'The bottom-box marking is not a recognized JJL/FAC format.',
            level: AtlasAuthenticitySignalLevel.caution,
            weight: -8,
          ),
        );
        evaluatedSignals.add(
          AtlasEvaluatedAuthenticitySignal(
            id: 'production-stamp-unreadable',
            area: AtlasInspectionArea.bottomStamp,
            category: AtlasEvidenceCategory.productionStamp,
            severity: AtlasSignalSeverity.advisory,
            disposition: AtlasSignalDisposition.observational,
            confidence: inspection.resolvedEvidenceConfidence,
            baseWeight: 0.0,
            rationale:
                'An unreadable or unsupported stamp format is insufficient evidence, not a contradiction.',
          ),
        );
      }
    }

    if (!hasStructuredVariantSticker) {
      _addLegacyCheck(
        value: inspection.stickerPrintClear,
        id: 'sticker-print',
        area: AtlasInspectionArea.windowSticker,
        category: AtlasEvidenceCategory.variantSticker,
        goodTitle: 'Sticker print appears clear',
        warningTitle: 'Sticker print needs comparison',
        warningMessage:
            'Blurred or uneven printing can warrant closer comparison.',
        displaySignals: displaySignals,
        evaluatedSignals: evaluatedSignals,
        confidence: inspection.resolvedEvidenceConfidence,
      );
      _addLegacyCheck(
        value: inspection.stickerCutEven,
        id: 'sticker-cut',
        area: AtlasInspectionArea.windowSticker,
        category: AtlasEvidenceCategory.variantSticker,
        goodTitle: 'Sticker cut appears even',
        warningTitle: 'Sticker cut needs comparison',
        warningMessage:
            'An uneven border or cut can warrant closer comparison.',
        displaySignals: displaySignals,
        evaluatedSignals: evaluatedSignals,
        confidence: inspection.resolvedEvidenceConfidence,
      );
    }

    if (!hasStructuredMacroPackaging) {
      _addLegacyCheck(
        value: inspection.typographyConsistent,
        id: 'typography',
        area: AtlasInspectionArea.packagingCopyright,
        category: AtlasEvidenceCategory.macroPackaging,
        goodTitle: 'Macro typography appears consistent',
        warningTitle: 'Packaging typography needs comparison',
        warningMessage:
            'Large typography or layout differences should be reviewed, allowing for legitimate factory variance.',
        displaySignals: displaySignals,
        evaluatedSignals: evaluatedSignals,
        confidence: inspection.resolvedEvidenceConfidence,
      );
      _addLegacyCheck(
        value: inspection.borderConsistent,
        id: 'box-border',
        area: AtlasInspectionArea.packagingCopyright,
        category: AtlasEvidenceCategory.macroPackaging,
        goodTitle: 'Macro box layout appears consistent',
        warningTitle: 'Packaging layout needs comparison',
        warningMessage:
            'Large border or layout differences should be reviewed, allowing for legitimate manufacturing variance.',
        displaySignals: displaySignals,
        evaluatedSignals: evaluatedSignals,
        confidence: inspection.resolvedEvidenceConfidence,
      );
    }

    if (inspection.hasCopyrightEvidence && !hasStructuredMacroPackaging) {
      displaySignals.add(
        const AtlasAuthenticitySignal(
          id: 'copyright',
          title: 'Copyright evidence recorded',
          message: 'Copyright text is preserved for comparison and review.',
          level: AtlasAuthenticitySignalLevel.support,
          weight: 5,
        ),
      );
    }

    if (inspection.hasAutograph == true && !hasStructuredAutographCoa) {
      if (inspection.hasCoa == true && inspection.hasAuthenticationEvidence) {
        displaySignals.add(
          const AtlasAuthenticitySignal(
            id: 'autograph-documented',
            title: 'Autograph documentation recorded',
            message:
                'A COA provider or certification number was supplied. Atlas has not independently verified it.',
            level: AtlasAuthenticitySignalLevel.support,
            weight: 10,
          ),
        );
      } else {
        displaySignals.add(
          const AtlasAuthenticitySignal(
            id: 'autograph-unverified',
            title: 'Autograph verification not supplied',
            message:
                'The autograph was recorded without provider-verification evidence. This does not mean the autograph is invalid.',
            level: AtlasAuthenticitySignalLevel.caution,
            weight: 0,
          ),
        );
      }
      evaluatedSignals.add(
        AtlasEvaluatedAuthenticitySignal(
          id: 'autograph-observation',
          area: AtlasInspectionArea.autograph,
          category: AtlasEvidenceCategory.autographCoa,
          severity: AtlasSignalSeverity.info,
          disposition: AtlasSignalDisposition.observational,
          confidence: inspection.resolvedEvidenceConfidence,
          baseWeight: 0.0,
          rationale:
              'Autograph and COA data are observational in Scanner 5A and do not independently create counterfeit concern.',
        ),
      );
    }
  }

  static void _evaluateStructuredObservations({
    required AtlasVisualInspection inspection,
    required AtlasInspectionReferenceCriteria reference,
    required List<AtlasEvaluatedAuthenticitySignal> evaluatedSignals,
    required List<AtlasAuthenticitySignal> displaySignals,
  }) {
    for (final AtlasVisualEvidenceObservation observation
        in inspection.observations) {
      switch (observation.category) {
        case AtlasEvidenceCategory.productionStamp:
          final String? prefix =
              observation.attributes['factoryPrefix'] as String?;
          final DateTime? parsedDate =
              observation.attributes['parsedDate'] as DateTime?;
          if (prefix == null ||
              parsedDate == null ||
              reference.knownRuns.isEmpty) {
            evaluatedSignals.add(
              AtlasEvaluatedAuthenticitySignal(
                id: observation.observationId,
                area: observation.area,
                category: observation.category,
                severity: AtlasSignalSeverity.info,
                disposition: AtlasSignalDisposition.observational,
                confidence: observation.confidence,
                baseWeight: 0.0,
                rationale:
                    'Production evidence was recorded without enough structured reference data for a contradiction test.',
              ),
            );
            continue;
          }

          final bool matchesKnownRun = reference.knownRuns.any(
            (AtlasProductionRunReference run) =>
                run.matchesStamp(prefix: prefix, date: parsedDate),
          );
          evaluatedSignals.add(
            AtlasEvaluatedAuthenticitySignal(
              id: observation.observationId,
              area: observation.area,
              category: observation.category,
              severity: matchesKnownRun
                  ? AtlasSignalSeverity.info
                  : AtlasSignalSeverity.critical,
              disposition: matchesKnownRun
                  ? AtlasSignalDisposition.supporting
                  : AtlasSignalDisposition.discrepancy,
              confidence: observation.confidence,
              baseWeight: matchesKnownRun ? 0.0 : 0.50,
              rationale: matchesKnownRun
                  ? 'Production code aligns with a recorded manufacturing run.'
                  : 'Production code conflicts with recorded factory/date windows.',
            ),
          );
          break;

        case AtlasEvidenceCategory.variantSticker:
          final bool explicitCriticalMismatch =
              observation.attributes['criticalReferenceMismatch'] == true;
          final bool referenceMismatch =
              observation.attributes['referenceMismatch'] == true;
          final bool visualMismatch =
              observation.attributes['visualMismatch'] == true;
          final bool resolvedVariantMismatch =
              observation.attributes['resolvedVariantMismatch'] == true;

          if (explicitCriticalMismatch ||
              referenceMismatch ||
              visualMismatch ||
              resolvedVariantMismatch) {
            final AtlasSignalSeverity severity = explicitCriticalMismatch
                ? AtlasSignalSeverity.critical
                : referenceMismatch || resolvedVariantMismatch
                ? AtlasSignalSeverity.moderate
                : AtlasSignalSeverity.advisory;
            final double baseWeight = explicitCriticalMismatch
                ? 0.50
                : referenceMismatch || resolvedVariantMismatch
                ? 0.25
                : 0.12;
            evaluatedSignals.add(
              AtlasEvaluatedAuthenticitySignal(
                id: observation.observationId,
                area: observation.area,
                category: observation.category,
                severity: severity,
                disposition: AtlasSignalDisposition.discrepancy,
                confidence: observation.confidence,
                baseWeight: baseWeight,
                rationale: explicitCriticalMismatch
                    ? 'A specialized sticker engine reported a high-signal contradiction against vetted reference evidence.'
                    : referenceMismatch
                    ? 'Observed sticker or variant evidence differs from the recorded legitimate reference families.'
                    : resolvedVariantMismatch
                    ? 'Observed sticker or variant evidence differs from the resolved catalog variant and should be confirmed.'
                    : 'A visible sticker print or cut inconsistency was recorded for collector review.',
              ),
            );
          }
          break;

        case AtlasEvidenceCategory.macroPackaging:
          final bool explicitCriticalMismatch =
              observation.attributes['criticalReferenceMismatch'] == true;
          final bool macroMismatch =
              observation.attributes['macroMismatch'] == true;
          if (explicitCriticalMismatch || macroMismatch) {
            evaluatedSignals.add(
              AtlasEvaluatedAuthenticitySignal(
                id: observation.observationId,
                area: observation.area,
                category: observation.category,
                severity: explicitCriticalMismatch
                    ? AtlasSignalSeverity.critical
                    : AtlasSignalSeverity.advisory,
                disposition: AtlasSignalDisposition.discrepancy,
                confidence: observation.confidence,
                baseWeight: explicitCriticalMismatch ? 0.50 : 0.12,
                rationale: explicitCriticalMismatch
                    ? 'A specialized packaging engine reported a high-signal contradiction against vetted reference evidence.'
                    : 'A macro packaging difference was observed and should be reviewed with manufacturing variance in mind.',
              ),
            );
          }
          break;

        case AtlasEvidenceCategory.autographCoa:
          final bool internalMismatch =
              observation.attributes['internalMismatch'] == true;
          final bool providerVerified =
              observation.attributes['providerVerified'] == true;
          final String documentationState =
              observation.attributes['documentationState'] as String? ?? '';

          if (internalMismatch) {
            displaySignals.add(
              const AtlasAuthenticitySignal(
                id: 'authentication-details-inconsistent',
                title: 'Authentication details need review',
                message:
                    'Observed COA text differs from manually recorded provider or certificate details. Confirm the document before relying on it.',
                level: AtlasAuthenticitySignalLevel.caution,
                weight: -8,
              ),
            );
          } else if (documentationState == 'supported') {
            displaySignals.add(
              const AtlasAuthenticitySignal(
                id: 'authentication-documentation-recorded',
                title: 'Authentication documentation recorded',
                message:
                    'Provider and certificate details were observed. Atlas has not independently verified the provider record.',
                level: AtlasAuthenticitySignalLevel.support,
                weight: 5,
              ),
            );
          }

          evaluatedSignals.add(
            AtlasEvaluatedAuthenticitySignal(
              id: observation.observationId,
              area: observation.area,
              category: observation.category,
              severity: internalMismatch
                  ? AtlasSignalSeverity.advisory
                  : AtlasSignalSeverity.info,
              disposition: internalMismatch
                  ? AtlasSignalDisposition.discrepancy
                  : providerVerified
                  ? AtlasSignalDisposition.supporting
                  : AtlasSignalDisposition.observational,
              confidence: observation.confidence,
              baseWeight: internalMismatch ? 0.12 : 0.0,
              rationale: internalMismatch
                  ? 'Observed authentication document text conflicts with separately entered provider or certificate details. This is an internal documentation inconsistency, not a provider-verification result.'
                  : providerVerified
                  ? 'An external authentication adapter reported a verified provider result.'
                  : 'Autograph and COA evidence was recorded without external provider verification.',
            ),
          );
          break;
      }
    }
  }

  static void _addLegacyCheck({
    required bool? value,
    required String id,
    required AtlasInspectionArea area,
    required AtlasEvidenceCategory category,
    required String goodTitle,
    required String warningTitle,
    required String warningMessage,
    required List<AtlasAuthenticitySignal> displaySignals,
    required List<AtlasEvaluatedAuthenticitySignal> evaluatedSignals,
    required double confidence,
  }) {
    if (value == null) return;

    if (value) {
      displaySignals.add(
        AtlasAuthenticitySignal(
          id: id,
          title: goodTitle,
          message: 'Collector-confirmed visual observation.',
          level: AtlasAuthenticitySignalLevel.support,
          weight: 5,
        ),
      );
      return;
    }

    displaySignals.add(
      AtlasAuthenticitySignal(
        id: id,
        title: warningTitle,
        message: warningMessage,
        level: AtlasAuthenticitySignalLevel.caution,
        weight: -8,
      ),
    );
    evaluatedSignals.add(
      AtlasEvaluatedAuthenticitySignal(
        id: id,
        area: area,
        category: category,
        severity: AtlasSignalSeverity.advisory,
        disposition: AtlasSignalDisposition.discrepancy,
        confidence: confidence,
        baseWeight: 0.12,
        rationale: warningMessage,
      ),
    );
  }

  static _ConcernAggregation _aggregateConcern(
    List<AtlasEvaluatedAuthenticitySignal> signals,
    List<String> audit,
  ) {
    final Map<AtlasEvidenceCategory, List<AtlasEvaluatedAuthenticitySignal>>
    grouped = <AtlasEvidenceCategory, List<AtlasEvaluatedAuthenticitySignal>>{};

    for (final AtlasEvaluatedAuthenticitySignal signal in signals) {
      if (!signal.isDiscrepancy) continue;
      grouped
          .putIfAbsent(
            signal.category,
            () => <AtlasEvaluatedAuthenticitySignal>[],
          )
          .add(signal);
    }

    double score = 0.0;
    int criticalCategories = 0;

    for (final MapEntry<
          AtlasEvidenceCategory,
          List<AtlasEvaluatedAuthenticitySignal>
        >
        entry
        in grouped.entries) {
      double raw = 0.0;
      bool hasCritical = false;
      for (final AtlasEvaluatedAuthenticitySignal signal in entry.value) {
        raw += signal.weightedConcern;
        hasCritical =
            hasCritical || signal.severity == AtlasSignalSeverity.critical;
      }

      if (hasCritical) {
        criticalCategories++;
      }

      final double clamped = raw.clamp(0.0, categoryConcernCap).toDouble();
      if (raw > categoryConcernCap) {
        audit.add(
          '${entry.key.name} concern was clamped from ${raw.toStringAsFixed(3)} to ${categoryConcernCap.toStringAsFixed(3)} to prevent correlated evidence from compounding.',
        );
      }
      score += clamped;
    }

    return _ConcernAggregation(
      score: score.clamp(0.0, 1.0).toDouble(),
      criticalCategories: criticalCategories,
    );
  }

  static AtlasInspectionReferenceCriteria _fallbackReference(
    ScanSession session,
  ) {
    final resolved = session.resolvedProduct;
    if (resolved == null) {
      return AtlasInspectionReferenceCriteria.unknown(
        productId: 'scan-${session.sessionId}',
      );
    }

    final List<String> variants = <String>[];
    if (resolved.variantName != null &&
        resolved.variantName!.trim().isNotEmpty) {
      variants.add(resolved.variantName!.trim());
    }

    return AtlasInspectionReferenceCriteria(
      productId: resolved.productId.value,
      upc: resolved.primaryBarcode,
      coverageLevel: AtlasReferenceCoverageLevel.limited,
      completenessScore: 0.35,
      legitimateVariantTypes: variants,
      provenance: <AtlasReferenceProvenance>[
        AtlasReferenceProvenance(
          sourceType: AtlasReferenceSourceType.inferredEstimate,
          sourceIdentifier: 'resolved-product-snapshot',
          lastVerifiedAt: DateTime.now().toUtc(),
        ),
      ],
    );
  }

  static AtlasAuthenticityAssessment _assessment({
    required AtlasAuthenticityConcernLevel concernLevel,
    required double evidenceConfidence,
    required double referenceCoverage,
    required double inspectionCoverage,
    required double aggregatedConcernScore,
    required String summary,
    required List<AtlasAuthenticitySignal> displaySignals,
    required List<AtlasEvaluatedAuthenticitySignal> evaluatedSignals,
    required List<AtlasInspectionArea> uninspectedAreas,
    required List<String> audit,
    required AtlasProductionStamp? productionStamp,
  }) {
    final AtlasAuthenticityStatus status = switch (concernLevel) {
      AtlasAuthenticityConcernLevel.insufficientData =>
        AtlasAuthenticityStatus.insufficientEvidence,
      AtlasAuthenticityConcernLevel.reviewRecommended ||
      AtlasAuthenticityConcernLevel.significantInconsistencies ||
      AtlasAuthenticityConcernLevel.strongCounterfeitIndicators =>
        AtlasAuthenticityStatus.reviewRecommended,
      AtlasAuthenticityConcernLevel.noObviousConcerns =>
        inspectionCoverage >= 0.70
            ? AtlasAuthenticityStatus.strongEvidence
            : AtlasAuthenticityStatus.developingEvidence,
    };

    return AtlasAuthenticityAssessment(
      status: status,
      concernLevel: concernLevel,
      evidenceConfidence: evidenceConfidence,
      referenceCoverage: referenceCoverage,
      inspectionCoverage: inspectionCoverage,
      aggregatedConcernScore: aggregatedConcernScore,
      summary: summary,
      signals: displaySignals,
      evaluatedSignals: evaluatedSignals,
      uninspectedAreas: uninspectedAreas,
      auditLog: audit,
      productionStamp: productionStamp,
    );
  }

  static String _summaryForConcern(AtlasAuthenticityConcernLevel concernLevel) {
    return switch (concernLevel) {
      AtlasAuthenticityConcernLevel.noObviousConcerns =>
        'No obvious concerns were found in the inspected evidence. This is not a guarantee of authenticity.',
      AtlasAuthenticityConcernLevel.reviewRecommended =>
        'One or more low-to-moderate inconsistencies should be reviewed before relying on this inspection.',
      AtlasAuthenticityConcernLevel.significantInconsistencies =>
        'Significant inconsistencies were found across the inspected evidence. Collector review is recommended.',
      AtlasAuthenticityConcernLevel.strongCounterfeitIndicators =>
        'Multiple independent high-signal contradictions were found. This is a warning assessment, not a definitive counterfeit determination.',
      AtlasAuthenticityConcernLevel.insufficientData =>
        'There is not enough reliable evidence or reference coverage to form an authenticity assessment.',
    };
  }
}

final class _ConcernAggregation {
  const _ConcernAggregation({
    required this.score,
    required this.criticalCategories,
  });

  final double score;
  final int criticalCategories;
}
