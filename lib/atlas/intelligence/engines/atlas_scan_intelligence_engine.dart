import '../../scan/models/scan_session.dart';
import '../../scan/workflow/identity_resolution_status.dart';
import '../models/atlas_scan_intelligence.dart';
import 'atlas_engine.dart';

class AtlasScanIntelligenceEngine
    extends AtlasEngine<ScanSession, AtlasScanIntelligence> {
  const AtlasScanIntelligenceEngine();

  @override
  String get id => 'atlas.scan-intelligence';

  @override
  String get name => 'Atlas Scan Intelligence Engine';

  @override
  String get description {
    return 'Produces collector-facing intelligence from a projected '
        'Atlas scan session.';
  }

  @override
  String get version => '1.0.0';

  @override
  List<String> validateInput(ScanSession input) {
    final List<String> issues = <String>[];

    if (input.sessionId.trim().isEmpty) {
      issues.add('The scan session must have a session ID.');
    }

    if (!input.hasDetectedCodes) {
      issues.add('The scan session does not contain detected code evidence.');
    }

    return List<String>.unmodifiable(issues);
  }

  @override
  AtlasScanIntelligence process(ScanSession input) {
    final List<AtlasScanInsight> insights = <AtlasScanInsight>[];

    _addIdentityInsight(
      session: input,
      insights: insights,
    );

    _addConfidenceInsight(
      session: input,
      insights: insights,
    );

    _addVariantInsight(
      session: input,
      insights: insights,
    );

    _addCollectorInsight(
      session: input,
      insights: insights,
    );

    _addMarketInsight(
      session: input,
      insights: insights,
    );

    _addSyncInsight(
      session: input,
      insights: insights,
    );

    _addWarningInsights(
      session: input,
      insights: insights,
    );

    return AtlasScanIntelligence(
      sessionId: input.sessionId,
      generatedAt: DateTime.now(),
      insights: insights,
    );
  }

  void _addIdentityInsight({
    required ScanSession session,
    required List<AtlasScanInsight> insights,
  }) {
    switch (session.resolutionStatus) {
      case IdentityResolutionStatus.resolvedLocal:
        insights.add(
          AtlasScanInsight(
            id: 'identity-resolved-local',
            type: AtlasScanInsightType.identity,
            title: 'Product Identified',
            message:
            'Atlas identified this collectible using local intelligence.',
            details: _identityDetails(session),
          ),
        );

      case IdentityResolutionStatus.resolvedRemote:
        insights.add(
          AtlasScanInsight(
            id: 'identity-resolved-remote',
            type: AtlasScanInsightType.identity,
            title: 'Product Identified',
            message:
            'Atlas identified this collectible using connected catalog intelligence.',
            details: _identityDetails(session),
          ),
        );

      case IdentityResolutionStatus.pendingSync:
        insights.add(
          AtlasScanInsight(
            id: 'identity-sync-pending',
            type: AtlasScanInsightType.identity,
            title: 'Product Identified',
            message:
            'Atlas identified this collectible locally. Additional connected intelligence is pending.',
            priority: AtlasScanInsightPriority.normal,
            details: _identityDetails(session),
          ),
        );

      case IdentityResolutionStatus.ambiguous:
        insights.add(
          const AtlasScanInsight(
            id: 'identity-ambiguous',
            type: AtlasScanInsightType.warning,
            title: 'Identity Review Required',
            message:
            'Atlas found more than one possible product identity.',
            priority: AtlasScanInsightPriority.high,
            recommendation:
            'Review the product, barcode, sticker, and variant details before continuing.',
          ),
        );

      case IdentityResolutionStatus.unresolved:
        insights.add(
          const AtlasScanInsight(
            id: 'identity-unresolved',
            type: AtlasScanInsightType.warning,
            title: 'Product Not Identified',
            message:
            'Atlas could not determine a confirmed product identity from the available evidence.',
            priority: AtlasScanInsightPriority.high,
            recommendation:
            'Try scanning the barcode again or search the Atlas catalog manually.',
          ),
        );

      case IdentityResolutionStatus.failed:
        insights.add(
          const AtlasScanInsight(
            id: 'identity-failed',
            type: AtlasScanInsightType.warning,
            title: 'Resolution Failed',
            message:
            'Atlas could not complete product identity resolution.',
            priority: AtlasScanInsightPriority.critical,
            recommendation:
            'Review the scan evidence and attempt a new scan.',
          ),
        );

      case IdentityResolutionStatus.notStarted:
      case IdentityResolutionStatus.resolving:
        break;
    }
  }

  void _addConfidenceInsight({
    required ScanSession session,
    required List<AtlasScanInsight> insights,
  }) {
    final int? confidencePercent =
    _confidencePercent(session.confidence);

    if (confidencePercent == null) {
      return;
    }

    final AtlasScanInsightPriority priority;
    final String message;

    if (confidencePercent >= 90) {
      priority = AtlasScanInsightPriority.normal;
      message =
      'Atlas has very high confidence in this product identification.';
    } else if (confidencePercent >= 75) {
      priority = AtlasScanInsightPriority.normal;
      message =
      'Atlas has strong confidence in this product identification.';
    } else if (confidencePercent >= 60) {
      priority = AtlasScanInsightPriority.normal;
      message =
      'Atlas has moderate confidence in this product identification.';
    } else {
      priority = AtlasScanInsightPriority.high;
      message =
      'Atlas has limited confidence in this product identification.';
    }

    insights.add(
      AtlasScanInsight(
        id: 'scan-confidence',
        type: AtlasScanInsightType.identity,
        title: 'Identification Confidence',
        message: message,
        priority: priority,
        details: <String>[
          '$confidencePercent% confidence',
          '${session.contributionCount} intelligence '
              '${session.contributionCount == 1 ? 'contribution' : 'contributions'}',
        ],
        recommendation: confidencePercent < 60
            ? 'Confirm the product number, sticker, and variant before adding it to your Vault.'
            : null,
      ),
    );
  }

  void _addVariantInsight({
    required ScanSession session,
    required List<AtlasScanInsight> insights,
  }) {
    if (!session.hasVariantResolution) {
      return;
    }

    if (session.requiresVariantConfirmation) {
      insights.add(
        const AtlasScanInsight(
          id: 'variant-confirmation-required',
          type: AtlasScanInsightType.variant,
          title: 'Variant Confirmation Required',
          message:
          'Atlas identified possible variant information that still needs collector confirmation.',
          priority: AtlasScanInsightPriority.high,
          recommendation:
          'Compare the sticker, finish, retailer exclusive, event, and packaging details.',
        ),
      );
      return;
    }

    insights.add(
      const AtlasScanInsight(
        id: 'variant-reviewed',
        type: AtlasScanInsightType.variant,
        title: 'Variant Evidence Reviewed',
        message:
        'Atlas processed the available variant evidence for this collectible.',
      ),
    );
  }

  void _addCollectorInsight({
    required ScanSession session,
    required List<AtlasScanInsight> insights,
  }) {
    if (!session.hasCollectorStatus) {
      return;
    }

    insights.add(
      const AtlasScanInsight(
        id: 'collector-status-available',
        type: AtlasScanInsightType.collection,
        title: 'Vault Comparison Available',
        message:
        'Atlas compared this collectible with the collector’s current Vault.',
      ),
    );
  }

  void _addMarketInsight({
    required ScanSession session,
    required List<AtlasScanInsight> insights,
  }) {
    if (!session.hasMarketData) {
      return;
    }

    insights.add(
      const AtlasScanInsight(
        id: 'market-evidence-available',
        type: AtlasScanInsightType.market,
        title: 'Market Evidence Available',
        message:
        'Atlas found market evidence connected to this collectible.',
        recommendation:
        'Review the market snapshot before recording or changing the item value.',
      ),
    );
  }

  void _addSyncInsight({
    required ScanSession session,
    required List<AtlasScanInsight> insights,
  }) {
    if (!session.requiresSync) {
      return;
    }

    insights.add(
      AtlasScanInsight(
        id: 'sync-required',
        type: AtlasScanInsightType.recommendation,
        title: 'Additional Intelligence Pending',
        message: session.isOffline
            ? 'Atlas is currently offline and cannot complete connected intelligence checks.'
            : 'Atlas has additional intelligence that still needs to synchronize.',
        priority: AtlasScanInsightPriority.normal,
        recommendation:
        'Keep the scan session available until synchronization completes.',
      ),
    );
  }

  void _addWarningInsights({
    required ScanSession session,
    required List<AtlasScanInsight> insights,
  }) {
    for (int index = 0;
    index < session.warnings.length;
    index++) {
      final String warning = session.warnings[index].trim();

      if (warning.isEmpty) {
        continue;
      }

      insights.add(
        AtlasScanInsight(
          id: 'session-warning-$index',
          type: AtlasScanInsightType.warning,
          title: 'Scan Warning',
          message: warning,
          priority: AtlasScanInsightPriority.high,
        ),
      );
    }
  }

  List<String> _identityDetails(ScanSession session) {
    final List<String> details = <String>[];

    final String? productId =
    session.atlasProductId?.value.trim();

    if (productId != null && productId.isNotEmpty) {
      details.add('Atlas Product ID: $productId');
    }

    final String? productName =
    session.catalogProduct?.displayName.trim();

    if (productName != null && productName.isNotEmpty) {
      details.add(productName);
    }

    return List<String>.unmodifiable(details);
  }

  int? _confidencePercent(double confidence) {
    if (!confidence.isFinite || confidence <= 0) {
      return null;
    }

    final double normalized =
    confidence <= 1 ? confidence * 100 : confidence;

    return normalized.round().clamp(0, 100);
  }
}