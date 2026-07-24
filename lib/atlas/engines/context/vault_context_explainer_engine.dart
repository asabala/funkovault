import '../../coordinator/atlas_dashboard_model.dart';
import '../../models/atlas_vault_query_summary.dart';
import '../intelligence/atlas_intelligence_engine.dart';
import 'vault_query_preview_engine.dart';
import 'vault_search_intelligence_engine.dart';

class VaultContextAnswer {
  const VaultContextAnswer({
    required this.title,
    required this.answer,
    required this.atlasTip,
    required this.suggestedQuestions,
    this.actionLabel,
    this.vaultFilterKey,
    this.vaultSearchQuery,
    this.minimumValue,
    this.maximumValue,
    this.vaultSortKey,
    this.unsupportedParts = const [],
    this.previewMatchCount,
    this.previewTotalValue,
    this.previewHighestValue,
    this.previewAverageValue,
    this.previewOwnedCount,
    this.previewWishlistCount,
    this.previewMissingValueCount,
  });

  final String title;
  final String answer;
  final String atlasTip;
  final List<String> suggestedQuestions;

  /// Optional label for a read-only navigation action.
  final String? actionLabel;

  /// Existing Entire Vault filter key to open.
  final String? vaultFilterKey;

  /// Existing Entire Vault text search to apply.
  final String? vaultSearchQuery;

  /// Optional inclusive minimum value.
  final double? minimumValue;

  /// Optional inclusive maximum value.
  final double? maximumValue;

  /// Optional Entire Vault sort key.
  final String? vaultSortKey;

  /// Recognized request details Atlas cannot currently apply.
  final List<String> unsupportedParts;

  /// Number of current Vault records matching the supported query.
  final int? previewMatchCount;
  final double? previewTotalValue;
  final double? previewHighestValue;
  final double? previewAverageValue;

  final int? previewOwnedCount;
  final int? previewWishlistCount;
  final int? previewMissingValueCount;

  bool get hasPreviewMatchCount => previewMatchCount != null;
  bool get hasPreviewSummary =>
      previewMatchCount != null &&
          previewTotalValue != null &&
          previewHighestValue != null &&
          previewAverageValue != null &&
          previewOwnedCount != null &&
          previewWishlistCount != null &&
          previewMissingValueCount != null;

  bool get hasUnsupportedParts => unsupportedParts.isNotEmpty;

  bool get hasVaultFilterAction =>
      actionLabel != null &&
          actionLabel!.trim().isNotEmpty &&
          vaultFilterKey != null &&
          vaultFilterKey!.trim().isNotEmpty;

  bool get hasVaultSearchAction =>
      actionLabel != null &&
          actionLabel!.trim().isNotEmpty &&
          vaultSearchQuery != null &&
          vaultSearchQuery!.trim().isNotEmpty;

  bool get hasVaultValueAction =>
      actionLabel != null &&
          actionLabel!.trim().isNotEmpty &&
          (minimumValue != null || maximumValue != null);

  bool get hasVaultSortAction =>
      actionLabel != null &&
          actionLabel!.trim().isNotEmpty &&
          vaultSortKey != null &&
          vaultSortKey!.trim().isNotEmpty;

  bool get hasVaultAction =>
      hasVaultFilterAction ||
          hasVaultSearchAction ||
          hasVaultValueAction ||
          hasVaultSortAction;
}

class VaultContextExplainerEngine {
  const VaultContextExplainerEngine({
    this.intelligenceEngine = const AtlasIntelligenceEngine(),
    this.searchEngine = const VaultSearchIntelligenceEngine(),
    this.previewEngine = const VaultQueryPreviewEngine(),
  });

  final AtlasIntelligenceEngine intelligenceEngine;
  final VaultSearchIntelligenceEngine searchEngine;
  final VaultQueryPreviewEngine previewEngine;

  VaultContextAnswer explain({
    required String question,
    required AtlasDashboardModel dashboard,
  }) {
    final normalizedQuestion = question.trim().toLowerCase();

    if (_asksAboutCount(normalizedQuestion)) {
      return _buildCountAnswer(dashboard);
    }

    if (_asksAboutValue(normalizedQuestion)) {
      return _buildValueAnswer(dashboard);
    }

    if (_asksAboutCleanup(normalizedQuestion)) {
      return _buildCleanupAnswer(dashboard);
    }

    if (_asksAboutMissingValues(normalizedQuestion)) {
      return _buildMissingValueAnswer(dashboard);
    }

    if (_asksAboutDuplicates(normalizedQuestion)) {
      return _buildDuplicateAnswer(dashboard);
    }

    if (_asksAboutHealth(normalizedQuestion)) {
      return _buildHealthAnswer(dashboard);
    }

    if (_asksAboutWishlist(normalizedQuestion)) {
      return _buildWishlistAnswer(dashboard);
    }

    if (_asksAboutConfidence(normalizedQuestion)) {
      return _buildConfidenceAnswer(dashboard);
    }

    final searchIntent = searchEngine.interpret(question);

    if (searchIntent.hasNavigationAction ||
        searchIntent.hasUnsupportedParts) {
      return _buildSearchIntentAnswer(
        intent: searchIntent,
        dashboard: dashboard,
      );
    }

    return _buildOverviewAnswer(dashboard);
  }

  VaultContextAnswer _buildCountAnswer(
      AtlasDashboardModel dashboard,
      ) {
    final countLabel = dashboard.totalPops == 1
        ? '1 collectible'
        : '${dashboard.totalPops} collectibles';

    return VaultContextAnswer(
      title: 'Vault Count',
      answer:
      'Your selected Vault currently contains $countLabel across '
          '${dashboard.uniqueCategories} '
          '${dashboard.uniqueCategories == 1 ? 'category' : 'categories'}.',
      atlasTip:
      'Atlas currently reports the number of saved collectible records. Quantity values may represent additional identical copies.',
      suggestedQuestions: const [
        'What is my total collection value?',
        'What should I clean up first?',
        'Show me my signed Pops',
      ],
    );
  }

  VaultContextAnswer _buildValueAnswer(
      AtlasDashboardModel dashboard,
      ) {
    if (dashboard.totalPops == 0) {
      return const VaultContextAnswer(
        title: 'Vault Value',
        answer:
        'Your selected Vault does not contain any collectibles yet, so no collection value is available.',
        atlasTip:
        'Add your first collectible and estimated value to begin building Atlas value intelligence.',
        suggestedQuestions: _defaultSuggestedQuestions,
      );
    }

    final averageValue = dashboard.totalValue / dashboard.totalPops;

    return VaultContextAnswer(
      title: 'Vault Value',
      answer:
      'Your selected Vault has a recorded value of '
          '\$${dashboard.totalValue.toStringAsFixed(2)}. '
          'The average recorded value per collectible is '
          '\$${averageValue.toStringAsFixed(2)}.',
      atlasTip: dashboard.missingValueCount > 0
          ? '${dashboard.missingValueCount} '
          '${dashboard.missingValueCount == 1 ? 'collectible still needs' : 'collectibles still need'} '
          'an estimated value, so the total is incomplete.'
          : 'All collectibles currently have estimated values recorded.',
      suggestedQuestions: const [
        'How many Pops need values?',
        'Show Pops worth over \$100',
        'Show my most valuable Pops',
      ],
    );
  }

  VaultContextAnswer _buildCleanupAnswer(
      AtlasDashboardModel dashboard,
      ) {
    final intelligenceReport = intelligenceEngine.analyze(
      pops: dashboard.pops,
      duplicateCount: dashboard.duplicateGroupCount,
      missingValueCount: dashboard.missingValueCount,
    );

    String? actionLabel;
    String? vaultFilterKey;

    if (dashboard.duplicateGroupCount > 0) {
      actionLabel = 'Review Possible Duplicates';
      vaultFilterKey = 'duplicates';
    } else if (dashboard.missingValueCount > 0) {
      actionLabel = 'Review Missing Values';
      vaultFilterKey = 'needsValue';
    }

    return VaultContextAnswer(
      title: intelligenceReport.primaryFocusTitle,
      answer: intelligenceReport.primaryFocusMessage,
      atlasTip:
      'Atlas prioritizes duplicate review before missing values because duplicate and variant decisions require careful collector verification.',
      suggestedQuestions: const [
        'Are there possible duplicate groups?',
        'How many Pops need values?',
        'Show me my variants',
      ],
      actionLabel: actionLabel,
      vaultFilterKey: vaultFilterKey,
    );
  }

  VaultContextAnswer _buildMissingValueAnswer(
      AtlasDashboardModel dashboard,
      ) {
    if (dashboard.missingValueCount == 0) {
      return const VaultContextAnswer(
        title: 'Missing Values',
        answer:
        'Every collectible in the selected Vault currently has an estimated value.',
        atlasTip:
        'Review values periodically so collection totals remain useful and accurate.',
        suggestedQuestions: _defaultSuggestedQuestions,
      );
    }

    return VaultContextAnswer(
      title: 'Missing Values',
      answer:
      '${dashboard.missingValueCount} '
          '${dashboard.missingValueCount == 1 ? 'collectible needs' : 'collectibles need'} '
          'an estimated value.',
      atlasTip:
      'Adding missing values will improve Vault totals, cleanup readiness, and Atlas Confidence.',
      suggestedQuestions: const [
        'What should I clean up first?',
        'What is my total collection value?',
        'Show me Pops with values',
      ],
      actionLabel: 'Review Missing Values',
      vaultFilterKey: 'needsValue',
    );
  }

  VaultContextAnswer _buildDuplicateAnswer(
      AtlasDashboardModel dashboard,
      ) {
    if (dashboard.duplicateGroupCount == 0) {
      return const VaultContextAnswer(
        title: 'Duplicate Review',
        answer:
        'Atlas has not identified any possible duplicate groups in the selected Vault.',
        atlasTip:
        'Different variants, stickers, exclusives, signed editions, and limited releases should remain separate collectible records.',
        suggestedQuestions: _defaultSuggestedQuestions,
      );
    }

    return VaultContextAnswer(
      title: 'Duplicate Review',
      answer:
      'Atlas found ${dashboard.duplicateGroupCount} possible duplicate '
          '${dashboard.duplicateGroupCount == 1 ? 'group' : 'groups'} '
          'that may need collector review.',
      atlasTip:
      'Do not merge records based only on name and number. Confirm variant, sticker, exclusive, signed, limited-edition, and other identity details first.',
      suggestedQuestions: const [
        'What should I clean up first?',
        'Show me my variants',
        'Show me stickered Pops',
      ],
      actionLabel: 'Review Possible Duplicates',
      vaultFilterKey: 'duplicates',
    );
  }

  VaultContextAnswer _buildHealthAnswer(
      AtlasDashboardModel dashboard,
      ) {
    final healthLabel = dashboard.vaultHealth.toStringAsFixed(0);

    String healthMessage;

    if (dashboard.vaultHealth >= 90) {
      healthMessage =
      'Your selected Vault is in strong condition with only minor cleanup needs.';
    } else if (dashboard.vaultHealth >= 70) {
      healthMessage =
      'Your selected Vault is healthy, but Atlas found some cleanup opportunities.';
    } else if (dashboard.vaultHealth >= 50) {
      healthMessage =
      'Your selected Vault needs attention before Atlas can provide stronger collection intelligence.';
    } else {
      healthMessage =
      'Your selected Vault has significant cleanup work remaining.';
    }

    return VaultContextAnswer(
      title: 'Vault Health',
      answer: 'Vault Health is currently $healthLabel%. $healthMessage',
      atlasTip:
      '${dashboard.missingValueCount} missing values and '
          '${dashboard.duplicateGroupCount} possible duplicate groups are currently affecting the score.',
      suggestedQuestions: const [
        'What should I clean up first?',
        'Are there possible duplicate groups?',
        'Show me my exclusives',
      ],
    );
  }

  VaultContextAnswer _buildWishlistAnswer(
      AtlasDashboardModel dashboard,
      ) {
    return VaultContextAnswer(
      title: 'Wishlist Summary',
      answer:
      'Your selected Vault currently includes ${dashboard.wishlistCount} '
          '${dashboard.wishlistCount == 1 ? 'wishlist collectible' : 'wishlist collectibles'}.',
      atlasTip:
      'Wishlist records stay in Atlas so you can preserve identity, value, and collecting-interest data without marking them as owned.',
      suggestedQuestions: const [
        'Show me my wishlist',
        'How many Pops are in my Vault?',
        'What is my total collection value?',
      ],
      actionLabel:
      dashboard.wishlistCount > 0 ? 'Open Wishlist' : null,
      vaultFilterKey:
      dashboard.wishlistCount > 0 ? 'wishlist' : null,
    );
  }

  VaultContextAnswer _buildConfidenceAnswer(
      AtlasDashboardModel dashboard,
      ) {
    return VaultContextAnswer(
      title: 'Atlas Confidence',
      answer:
      'Atlas Confidence is currently '
          '${dashboard.confidence.score.toStringAsFixed(0)}%. '
          '${dashboard.confidence.message}',
      atlasTip:
      'Complete values and accurate collector identity details help Atlas produce stronger recommendations.',
      suggestedQuestions: const [
        'How healthy is my Vault?',
        'What should I clean up first?',
        'Show me my signed Pops',
      ],
    );
  }

  VaultContextAnswer _buildSearchIntentAnswer({
    required VaultSearchIntent intent,
    required AtlasDashboardModel dashboard,
  }) {
    final querySummary = AtlasVaultQuerySummary(
      filterKey: intent.filterKey,
      searchQuery: intent.searchQuery,
      minimumValue: intent.minimumValue,
      maximumValue: intent.maximumValue,
      sortKey: intent.sortKey,
      unsupportedParts: intent.unsupportedParts,
    );
    final previewResult = intent.hasNavigationAction
        ? previewEngine.preview(
      pops: dashboard.pops,
      filterKey: intent.filterKey,
      searchQuery: intent.searchQuery,
      minimumValue: intent.minimumValue,
      maximumValue: intent.maximumValue,
      sortKey: intent.sortKey,
    )
        : null;
    final unsupportedText = querySummary.unsupportedText;

    String answer;

    if (intent.hasNavigationAction) {
      answer = querySummary.confirmationText;

      if (unsupportedText != null) {
        answer = '$answer\n\n$unsupportedText';
      }
    } else {
      answer = unsupportedText ??
          'Atlas could not identify supported Vault search criteria.';
    }

    String atlasTip;

    if (intent.hasUnsupportedParts &&
        intent.hasNavigationAction) {
      atlasTip =
      'Atlas will apply the supported criteria only. Unsupported criteria will not affect the Entire Vault results.';
    } else if (intent.hasUnsupportedParts) {
      atlasTip =
      'Try searching by collectible name, number, category, series, owner, Vault status, recorded value, or supported sorting.';
    } else if (intent.hasValueRange) {
      atlasTip =
      'Atlas will use the recorded value on each collectible and apply the requested inclusive value range.';
    } else if (intent.hasFilter) {
      atlasTip =
      'Atlas will use an existing Entire Vault filter, so the same trusted collection rules remain in effect.';
    } else if (intent.hasSearch) {
      atlasTip =
      'Atlas will use the existing Entire Vault search across name, number, category, series, and owner.';
    } else if (intent.hasSort) {
      atlasTip =
      'Atlas will use the existing Entire Vault sorting system.';
    } else {
      atlasTip =
      'Atlas will open Entire Vault using the supported request details.';
    }

    return VaultContextAnswer(
      title: intent.hasUnsupportedParts
          ? intent.hasNavigationAction
          ? 'Partially Supported Request'
          : 'Unsupported Vault Request'
          : intent.title,
      answer: answer,
      atlasTip: atlasTip,
      suggestedQuestions: const [
        'Show me my signed Pops',
        'Find my exclusives',
        'Show Pops worth over \$100',
        'Show items between \$25 and \$100',
        'Show my most valuable Pops',
        'Find Batman',
      ],
      actionLabel: intent.hasNavigationAction
          ? _actionLabelForIntent(intent)
          : null,
      vaultFilterKey: intent.filterKey,
      vaultSearchQuery: intent.searchQuery,
      minimumValue: intent.minimumValue,
      maximumValue: intent.maximumValue,
      vaultSortKey: intent.sortKey,
      unsupportedParts: intent.unsupportedParts,
      previewMatchCount: previewResult?.matchCount,
      previewTotalValue: previewResult?.totalValue,
      previewHighestValue: previewResult?.highestValue,
      previewAverageValue: previewResult?.averageValue,
      previewOwnedCount: previewResult?.ownedCount,
      previewWishlistCount: previewResult?.wishlistCount,
      previewMissingValueCount: previewResult?.missingValueCount,
    );
  }

  String _actionLabelForIntent(
      VaultSearchIntent intent,
      ) {
    if (intent.hasValueRange) {
      return 'Open Value Results';
    }

    if (intent.hasSearch) {
      return 'Search Entire Vault';
    }

    if (intent.hasSort && !intent.hasFilter) {
      return 'Open Sorted Vault';
    }

    return 'Open Filtered Vault';
  }

  VaultContextAnswer _buildOverviewAnswer(
      AtlasDashboardModel dashboard,
      ) {
    final intelligenceReport = intelligenceEngine.analyze(
      pops: dashboard.pops,
      duplicateCount: dashboard.duplicateGroupCount,
      missingValueCount: dashboard.missingValueCount,
    );

    return VaultContextAnswer(
      title: 'Vault Overview',
      answer:
      'Your selected Vault contains ${dashboard.totalPops} '
          '${dashboard.totalPops == 1 ? 'collectible' : 'collectibles'} '
          'with a recorded value of '
          '\$${dashboard.totalValue.toStringAsFixed(2)}. '
          'Vault Health is ${dashboard.vaultHealth.toStringAsFixed(0)}%. '
          '${intelligenceReport.primaryFocusMessage}',
      atlasTip:
      'Atlas is answering from trusted Vault metrics and existing collection engines only.',
      suggestedQuestions: _defaultSuggestedQuestions,
    );
  }

  bool _asksAboutCount(String question) {
    return question.contains('how many') &&
        (question.contains('pop') ||
            question.contains('collectible') ||
            question.contains('vault'));
  }

  bool _asksAboutValue(String question) {
    final isValueRangeRequest =
        question.contains('over') ||
            question.contains('above') ||
            question.contains('under') ||
            question.contains('below') ||
            question.contains('between') ||
            question.contains('most valuable') ||
            question.contains('highest value') ||
            question.contains('most expensive');

    if (isValueRangeRequest) {
      return false;
    }

    return question.contains('total value') ||
        question.contains('collection value') ||
        question.contains('vault value') ||
        question.contains('worth');
  }

  bool _asksAboutCleanup(String question) {
    return question.contains('clean up') ||
        question.contains('cleanup') ||
        question.contains('fix first') ||
        question.contains('review first') ||
        question.contains('priority');
  }

  bool _asksAboutMissingValues(String question) {
    return question.contains('missing value') ||
        question.contains('need value') ||
        question.contains('needs value') ||
        question.contains('without value');
  }

  bool _asksAboutDuplicates(String question) {
    return question.contains('duplicate') ||
        question.contains('same pop') ||
        question.contains('matching record');
  }

  bool _asksAboutHealth(String question) {
    return question.contains('health') ||
        question.contains('healthy') ||
        question.contains('condition of my vault');
  }

  bool _asksAboutWishlist(String question) {
    return question.contains('how many') &&
        question.contains('wishlist');
  }

  bool _asksAboutConfidence(String question) {
    return question.contains('confidence') ||
        question.contains('accuracy') ||
        question.contains('trust');
  }

  static const List<String> _defaultSuggestedQuestions = [
    'How many Pops are in my Vault?',
    'What is my total collection value?',
    'What should I clean up first?',
    'Show me my signed Pops',
    'Show Pops worth over \$100',
    'Find Batman',
  ];
}