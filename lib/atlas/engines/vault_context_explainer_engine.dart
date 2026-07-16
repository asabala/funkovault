import '../coordinator/atlas_dashboard_model.dart';
import 'atlas_intelligence_engine.dart';

class VaultContextAnswer {
  const VaultContextAnswer({
    required this.title,
    required this.answer,
    required this.atlasTip,
    required this.suggestedQuestions,
    this.actionLabel,
    this.vaultFilterKey,
  });

  final String title;
  final String answer;
  final String atlasTip;
  final List<String> suggestedQuestions;

  /// Optional read-only navigation action.
  final String? actionLabel;

  /// Existing Entire Vault filter key to open.
  final String? vaultFilterKey;

  bool get hasVaultAction =>
      actionLabel != null &&
          actionLabel!.trim().isNotEmpty &&
          vaultFilterKey != null &&
          vaultFilterKey!.trim().isNotEmpty;
}

class VaultContextExplainerEngine {
  const VaultContextExplainerEngine({
    this.intelligenceEngine = const AtlasIntelligenceEngine(),
  });

  final AtlasIntelligenceEngine intelligenceEngine;

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
        'How healthy is my Vault?',
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
        'How healthy is my Vault?',
        'What should I clean up first?',
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
        'How healthy is my Vault?',
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
        'How healthy is my Vault?',
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
        'How many Pops need values?',
        'How healthy is my Vault?',
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
        'How many Pops need values?',
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
        'How many Pops are in my Vault?',
        'What is my total collection value?',
        'How healthy is my Vault?',
      ],
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
        'How many Pops need values?',
      ],
    );
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
    return question.contains('wishlist');
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
    'How many Pops need values?',
    'Are there possible duplicate groups?',
    'How healthy is my Vault?',
  ];
}