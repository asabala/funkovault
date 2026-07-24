import '../../../models/activity.dart';
import '../../../models/pop.dart';
import '../intelligence/atlas_intelligence_engine.dart';

class PopContextAnswer {
  const PopContextAnswer({
    required this.title,
    required this.answer,
    required this.atlasTip,
    required this.suggestedQuestions,
  });

  final String title;
  final String answer;
  final String atlasTip;
  final List<String> suggestedQuestions;
}

class PopContextExplainerEngine {
  const PopContextExplainerEngine({
    this.intelligenceEngine = const AtlasIntelligenceEngine(),
  });

  final AtlasIntelligenceEngine intelligenceEngine;

  PopContextAnswer explain({
    required String question,
    required Pop pop,
    required List<Activity> activities,
  }) {
    final normalizedQuestion = question.trim().toLowerCase();

    final activitySummary = intelligenceEngine.analyzePopActivity(
      pop: pop,
      activities: activities,
    );

    if (_asksAboutValue(normalizedQuestion)) {
      return _buildValueAnswer(
        pop: pop,
        activities: activities,
      );
    }

    if (_asksAboutQuantity(normalizedQuestion)) {
      return _buildQuantityAnswer(
        pop: pop,
        activities: activities,
      );
    }

    if (_asksAboutOwnership(normalizedQuestion)) {
      return _buildOwnershipAnswer(
        pop: pop,
        activities: activities,
      );
    }

    if (_asksAboutIdentity(normalizedQuestion)) {
      return _buildIdentityAnswer(pop);
    }

    if (_asksAboutHistory(normalizedQuestion)) {
      return PopContextAnswer(
        title: 'Collectible History',
        answer: activitySummary.summary,
        atlasTip: activitySummary.hasActivity
            ? 'Atlas found ${activitySummary.activityCount} recorded '
            '${activitySummary.activityCount == 1 ? 'event' : 'events'} '
            'for this collectible.'
            : 'Future value, quantity, ownership, and detail changes will appear here.',
        suggestedQuestions: _defaultSuggestedQuestions,
      );
    }

    return PopContextAnswer(
      title: 'About ${pop.name}',
      answer: _buildOverviewAnswer(
        pop: pop,
        activitySummary: activitySummary.summary,
      ),
      atlasTip:
      'Atlas is currently answering from trusted Vault data and recorded activity only.',
      suggestedQuestions: _defaultSuggestedQuestions,
    );
  }

  PopContextAnswer _buildValueAnswer({
    required Pop pop,
    required List<Activity> activities,
  }) {
    final matchingActivities = _matchingActivities(
      pop: pop,
      activities: activities,
    );

    final valueUpdates = matchingActivities
        .where(
          (activity) => activity.action == 'value_updated',
    )
        .toList();

    final currentValueLabel = pop.value <= 0
        ? 'No estimated value is currently saved.'
        : 'The current estimated value is '
        '\$${pop.value.toStringAsFixed(2)}.';

    final historyLabel = valueUpdates.isEmpty
        ? 'Atlas has not recorded a value change for this collectible yet.'
        : valueUpdates.length == 1
        ? 'Atlas has recorded one value update.'
        : 'Atlas has recorded ${valueUpdates.length} value updates.';

    return PopContextAnswer(
      title: 'Value Intelligence',
      answer: '$currentValueLabel $historyLabel',
      atlasTip: pop.value <= 0
          ? 'Adding an estimated value will improve Vault totals and Atlas Confidence.'
          : 'Review values periodically so Atlas can provide more accurate collection insights.',
      suggestedQuestions: const [
        'What changed with this Pop?',
        'How many are in my collection?',
        'What is this Pop’s collector identity?',
      ],
    );
  }

  PopContextAnswer _buildQuantityAnswer({
    required Pop pop,
    required List<Activity> activities,
  }) {
    final matchingActivities = _matchingActivities(
      pop: pop,
      activities: activities,
    );

    final quantityUpdates = matchingActivities
        .where(
          (activity) =>
      activity.action == 'quantity_updated' ||
          activity.action == 'quantity_increased',
    )
        .length;

    final updateLabel = quantityUpdates == 0
        ? 'Atlas has not recorded a quantity adjustment yet.'
        : quantityUpdates == 1
        ? 'Atlas has recorded one quantity adjustment.'
        : 'Atlas has recorded $quantityUpdates quantity adjustments.';

    return PopContextAnswer(
      title: 'Quantity Intelligence',
      answer:
      'Your collection currently lists ${pop.quantity} ${pop.quantity == 1 ? 'copy' : 'copies'} of ${pop.name}. $updateLabel',
      atlasTip:
      'Quantity should represent identical copies only. Different variants, stickers, exclusives, or signed editions should remain separate records.',
      suggestedQuestions: const [
        'What changed with this Pop?',
        'Was this moved to the wishlist?',
        'What is this Pop’s collector identity?',
      ],
    );
  }

  PopContextAnswer _buildOwnershipAnswer({
    required Pop pop,
    required List<Activity> activities,
  }) {
    final matchingActivities = _matchingActivities(
      pop: pop,
      activities: activities,
    );

    final movedToWishlist = matchingActivities.any(
          (activity) => activity.action == 'wishlist_added',
    );

    final movedToOwned = matchingActivities.any(
          (activity) => activity.action == 'wishlist_removed',
    );

    String historyLabel;

    if (movedToWishlist && movedToOwned) {
      historyLabel =
      'Atlas recorded movement between the wishlist and owned collection.';
    } else if (movedToWishlist) {
      historyLabel = 'Atlas recorded a move to the wishlist.';
    } else if (movedToOwned) {
      historyLabel = 'Atlas recorded a move to the owned collection.';
    } else {
      historyLabel =
      'Atlas has not recorded an ownership-status change yet.';
    }

    return PopContextAnswer(
      title: 'Ownership Status',
      answer:
      '${pop.name} is currently marked as ${pop.isWishlist ? 'Wishlist' : 'Owned'} for ${pop.owner}. $historyLabel',
      atlasTip:
      'Wishlist status changes availability, but it does not remove the collectible record or its saved identity details.',
      suggestedQuestions: const [
        'What changed with this Pop?',
        'What is its current value?',
        'How many are in my collection?',
      ],
    );
  }

  PopContextAnswer _buildIdentityAnswer(Pop pop) {
    final identityParts = <String>[];

    _addMeaningfulIdentity(
      identityParts,
      label: 'Variant',
      value: pop.variant,
      ignoredValues: const ['common', 'standard'],
    );

    _addMeaningfulIdentity(
      identityParts,
      label: 'Exclusive',
      value: pop.retailExclusive,
      ignoredValues: const ['none', 'no'],
    );

    _addMeaningfulIdentity(
      identityParts,
      label: 'Sticker',
      value: pop.eventSticker,
      ignoredValues: const ['none', 'no'],
    );

    _addMeaningfulIdentity(
      identityParts,
      label: 'Limited edition',
      value: pop.limitedEdition,
      ignoredValues: const ['none', 'no'],
    );

    _addMeaningfulIdentity(
      identityParts,
      label: 'Signature',
      value: pop.signature,
      ignoredValues: const ['unsigned', 'none', 'no'],
    );

    final identityLabel = identityParts.isEmpty
        ? '${pop.name} is currently recorded as a common or standard release.'
        : '${pop.name} is recorded with: ${identityParts.join(', ')}.';

    return PopContextAnswer(
      title: 'Collector Identity',
      answer: identityLabel,
      atlasTip:
      'Variant, sticker, exclusive, limited-edition, and signature details help Atlas avoid treating different releases as duplicates.',
      suggestedQuestions: const [
        'What changed with this Pop?',
        'What is its current value?',
        'Was this moved to the wishlist?',
      ],
    );
  }

  String _buildOverviewAnswer({
    required Pop pop,
    required String activitySummary,
  }) {
    final valueLabel = pop.value <= 0
        ? 'no estimated value saved'
        : 'an estimated value of \$${pop.value.toStringAsFixed(2)}';

    return '${pop.name}'
        '${pop.number.trim().isEmpty ? '' : ' #${pop.number}'} '
        'is currently ${pop.isWishlist ? 'on the wishlist' : 'owned'} '
        'by ${pop.owner}, with quantity ${pop.quantity} and $valueLabel. '
        '$activitySummary';
  }

  List<Activity> _matchingActivities({
    required Pop pop,
    required List<Activity> activities,
  }) {
    final matchingActivities = activities
        .where(
          (activity) => _matchesPop(
        activity: activity,
        pop: pop,
      ),
    )
        .toList();

    matchingActivities.sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
    );

    return matchingActivities;
  }

  bool _matchesPop({
    required Activity activity,
    required Pop pop,
  }) {
    final activityPopId = activity.popId.trim();
    final popId = pop.id.trim();

    if (activityPopId.isNotEmpty && popId.isNotEmpty) {
      return activityPopId == popId;
    }

    final activityName = activity.popName.trim().toLowerCase();
    final popName = pop.name.trim().toLowerCase();

    if (activityName != popName) {
      return false;
    }

    final activityNumber = activity.popNumber.trim().toLowerCase();
    final popNumber = pop.number.trim().toLowerCase();

    if (activityNumber.isEmpty || popNumber.isEmpty) {
      return true;
    }

    return activityNumber == popNumber;
  }

  void _addMeaningfulIdentity(
      List<String> parts, {
        required String label,
        required String value,
        required List<String> ignoredValues,
      }) {
    final cleaned = value.trim();
    final normalized = cleaned.toLowerCase();

    if (cleaned.isEmpty ||
        ignoredValues.contains(normalized) ||
        normalized == 'n/a' ||
        normalized == 'na') {
      return;
    }

    parts.add('$label: $cleaned');
  }

  bool _asksAboutValue(String question) {
    return question.contains('value') ||
        question.contains('worth') ||
        question.contains('price');
  }

  bool _asksAboutQuantity(String question) {
    return question.contains('quantity') ||
        question.contains('how many') ||
        question.contains('copies');
  }

  bool _asksAboutOwnership(String question) {
    return question.contains('wishlist') ||
        question.contains('owned') ||
        question.contains('ownership') ||
        question.contains('who owns');
  }

  bool _asksAboutIdentity(String question) {
    return question.contains('identity') ||
        question.contains('variant') ||
        question.contains('sticker') ||
        question.contains('exclusive') ||
        question.contains('signed') ||
        question.contains('signature') ||
        question.contains('limited');
  }

  bool _asksAboutHistory(String question) {
    return question.contains('changed') ||
        question.contains('history') ||
        question.contains('activity') ||
        question.contains('updated') ||
        question.contains('timeline');
  }

  static const List<String> _defaultSuggestedQuestions = [
    'What changed with this Pop?',
    'What is its current value?',
    'How many are in my collection?',
    'Was this moved to the wishlist?',
    'What is this Pop’s collector identity?',
  ];
}