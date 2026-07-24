import '../contributions/contribution_collection.dart';
import '../contributions/contribution_conflict_policy.dart';
import '../contributions/intelligence_contribution.dart';
import '../../identity/product/atlas_product_id.dart';
import '../results/collector_item_status.dart';
import '../results/market_value_snapshot.dart';
import '../results/scan_variant_status.dart';
import '../workflow/identity_resolution_status.dart';
import '../workflow/scan_intent.dart';
import '../workflow/scan_performance_mode.dart';
import 'scan_code.dart';
import 'scan_image.dart';
import 'scanner_type.dart';
import 'visual_identity.dart';

// Describes the lifecycle of an Atlas scan session.
enum ScanSessionStatus {
  created,
  scanning,
  analyzing,
  resolving,
  awaitingConfirmation,
  completed,
  cancelled,
  failed,
}

// Immutable orchestration model for one Atlas scanning workflow.
//
// A session begins when a collector opens the scanner and continues
// through code detection, visual analysis, identity resolution,
// market lookup, Vault matching, and briefing generation.
class ScanSession {
  ScanSession({
    required this.sessionId,
    required this.startedAt,
    required this.intent,
    required this.performanceMode,
    required this.scannerType,
    this.status = ScanSessionStatus.created,
    this.completedAt,
    List<ScanCode> detectedCodes = const [],
    this.bestCandidate,
    this.visualIdentity = const VisualIdentity(),
    this.resolutionStatus =
        IdentityResolutionStatus.notStarted,
    this.atlasProductId,
    this.marketSnapshot,
    this.collectorStatus,
    this.variantResolution,
    ContributionCollection? contributions,
    List<ScanImage> images = const [],
    this.confidence = 0.0,
    this.isOffline = false,
    this.requiresSync = false,
    List<String> notes = const [],
    List<String> warnings = const [],
  })  : detectedCodes =
  List<ScanCode>.unmodifiable(detectedCodes),
        contributions =
            contributions ?? ContributionCollection.empty,
        images = List<ScanImage>.unmodifiable(images),
        notes = List<String>.unmodifiable(notes),
        warnings = List<String>.unmodifiable(warnings);

  final String sessionId;

  final DateTime startedAt;

  final DateTime? completedAt;

  final ScanSessionStatus status;

  final ScanIntent intent;

  final ScanPerformanceMode performanceMode;

  final ScannerType scannerType;

  final List<ScanCode> detectedCodes;

  final ScanCode? bestCandidate;

  final VisualIdentity visualIdentity;

  final IdentityResolutionStatus resolutionStatus;

  final AtlasProductId? atlasProductId;

  final MarketValueSnapshot? marketSnapshot;

  final CollectorItemStatus? collectorStatus;

  final ScanVariantResolution? variantResolution;

  final ContributionCollection contributions;

  final List<ScanImage> images;

  final double confidence;

  final bool isOffline;

  final bool requiresSync;

  final List<String> notes;

  final List<String> warnings;

  bool get hasDetectedCodes {
    return detectedCodes.isNotEmpty;
  }

  bool get hasBestCandidate {
    return bestCandidate != null;
  }

  bool get hasVisualEvidence {
    return visualIdentity.isNotEmpty;
  }

  bool get hasResolvedProduct {
    return atlasProductId != null &&
        resolutionStatus.isResolved;
  }

  bool get hasMarketData {
    return marketSnapshot?.hasMarketEvidence ?? false;
  }

  bool get hasCollectorStatus {
    return collectorStatus != null;
  }

  bool get hasVariantResolution {
    return variantResolution != null;
  }

  bool get hasContributions {
    return contributions.isNotEmpty;
  }

  int get contributionCount {
    return contributions.length;
  }

  bool hasContributionOfType<
  T extends IntelligenceContribution>() {
    return contributions.ofType<T>().isNotEmpty;
  }

  T? latestContributionOfType<
  T extends IntelligenceContribution>() {
    return contributions.latestOfType<T>();
  }

  bool get requiresVariantConfirmation {
    return variantResolution?.requiresConfirmation ?? false;
  }

  bool get hasImages {
    return images.isNotEmpty;
  }

  bool get hasOriginalImage {
    return images.any(
          (ScanImage image) => image.isOriginal,
    );
  }

  bool get hasProcessedImage {
    return images.any(
          (ScanImage image) => image.isProcessed,
    );
  }

  bool get isActive {
    return status == ScanSessionStatus.scanning ||
        status == ScanSessionStatus.analyzing ||
        status == ScanSessionStatus.resolving;
  }

  bool get isCompleted {
    return status == ScanSessionStatus.completed;
  }

  bool get requiresUserAction {
    return status ==
        ScanSessionStatus.awaitingConfirmation ||
        resolutionStatus.requiresUserReview ||
        requiresVariantConfirmation;
  }

  bool get canBuildBriefing {
    return hasResolvedProduct &&
        resolutionStatus.isResolved;
  }

  Duration get elapsed {
    final DateTime end =
        completedAt ?? DateTime.now();

    return end.difference(startedAt);
  }

  ScanImage? get originalImage {
    for (final ScanImage image in images) {
      if (image.type == ScanImageType.original) {
        return image;
      }
    }

    return null;
  }

  ScanImage? get processedImage {
    for (final ScanImage image in images) {
      if (image.type == ScanImageType.processed) {
        return image;
      }
    }

    return null;
  }

  ScanSession copyWith({
    String? sessionId,
    DateTime? startedAt,
    DateTime? completedAt,
    ScanSessionStatus? status,
    ScanIntent? intent,
    ScanPerformanceMode? performanceMode,
    ScannerType? scannerType,
    List<ScanCode>? detectedCodes,
    ScanCode? bestCandidate,
    VisualIdentity? visualIdentity,
    IdentityResolutionStatus? resolutionStatus,
    AtlasProductId? atlasProductId,
    MarketValueSnapshot? marketSnapshot,
    CollectorItemStatus? collectorStatus,
    ScanVariantResolution? variantResolution,
    ContributionCollection? contributions,
    List<ScanImage>? images,
    double? confidence,
    bool? isOffline,
    bool? requiresSync,
    List<String>? notes,
    List<String>? warnings,
  }) {
    return ScanSession(
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      intent: intent ?? this.intent,
      performanceMode:
      performanceMode ?? this.performanceMode,
      scannerType: scannerType ?? this.scannerType,
      detectedCodes:
      detectedCodes ?? this.detectedCodes,
      bestCandidate:
      bestCandidate ?? this.bestCandidate,
      visualIdentity:
      visualIdentity ?? this.visualIdentity,
      resolutionStatus:
      resolutionStatus ?? this.resolutionStatus,
      atlasProductId:
      atlasProductId ?? this.atlasProductId,
      marketSnapshot:
      marketSnapshot ?? this.marketSnapshot,
      collectorStatus:
      collectorStatus ?? this.collectorStatus,
      variantResolution:
      variantResolution ?? this.variantResolution,
      contributions:
      contributions ?? this.contributions,
      images: images ?? this.images,
      confidence: confidence ?? this.confidence,
      isOffline: isOffline ?? this.isOffline,
      requiresSync:
      requiresSync ?? this.requiresSync,
      notes: notes ?? this.notes,
      warnings: warnings ?? this.warnings,
    );
  }

  ScanSession addDetectedCode(
      ScanCode code, {
        bool makeBestCandidate = false,
      }) {
    final bool alreadyDetected = detectedCodes.any(
          (ScanCode existing) {
        return existing.format == code.format &&
            existing.normalizedValue ==
                code.normalizedValue;
      },
    );

    final List<ScanCode> updatedCodes =
    alreadyDetected
        ? detectedCodes
        : <ScanCode>[
      ...detectedCodes,
      code,
    ];

    return copyWith(
      detectedCodes: updatedCodes,
      bestCandidate:
      makeBestCandidate ? code : bestCandidate,
    );
  }
  ScanSession addContribution(
      IntelligenceContribution contribution, {
        ContributionConflictPolicy conflictPolicy =
            ContributionConflictPolicy.reject,
      }) {
    return copyWith(
      contributions: contributions.add(
        contribution,
        conflictPolicy: conflictPolicy,
      ),
    );
  }

  ScanSession addContributions(
      Iterable<IntelligenceContribution> values, {
        ContributionConflictPolicy conflictPolicy =
            ContributionConflictPolicy.reject,
      }) {
    return copyWith(
      contributions: contributions.addAll(
        values,
        conflictPolicy: conflictPolicy,
      ),
    );
  }

  ScanSession removeContributionById(
      String contributionId,
      ) {
    final ContributionCollection updated =
    contributions.removeById(contributionId);

    if (identical(updated, contributions)) {
      return this;
    }

    return copyWith(contributions: updated);
  }

  ScanSession removeContributionsFromEngine(
      String engineId,
      ) {
    final ContributionCollection updated =
    contributions.removeFromEngine(engineId);

    if (identical(updated, contributions)) {
      return this;
    }

    return copyWith(contributions: updated);
  }
  ScanSession addImage(ScanImage image) {
    final List<ScanImage> updatedImages =
    images
        .where(
          (ScanImage existing) =>
      existing.imageId != image.imageId,
    )
        .toList()
      ..add(image);

    return copyWith(images: updatedImages);
  }

  ScanSession addNote(String note) {
    final String normalized = note.trim();

    if (normalized.isEmpty ||
        notes.contains(normalized)) {
      return this;
    }

    return copyWith(
      notes: <String>[
        ...notes,
        normalized,
      ],
    );
  }

  ScanSession addWarning(String warning) {
    final String normalized = warning.trim();

    if (normalized.isEmpty ||
        warnings.contains(normalized)) {
      return this;
    }

    return copyWith(
      warnings: <String>[
        ...warnings,
        normalized,
      ],
    );
  }

  @override
  String toString() {
    return 'ScanSession('
        'sessionId: $sessionId, '
        'status: ${status.name}, '
        'intent: ${intent.name}, '
        'codes: ${detectedCodes.length}, '
        'images: ${images.length}, '
        'resolutionStatus: ${resolutionStatus.name}, '
        'atlasProductId: $atlasProductId, '
        'confidence: $confidence, '
        'isOffline: $isOffline, '
        'requiresSync: $requiresSync'
        ')';
  }
}