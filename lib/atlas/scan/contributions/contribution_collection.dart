import 'contribution_category.dart';
import 'contribution_conflict_policy.dart';
import 'intelligence_contribution.dart';

// Immutable collection of intelligence contributed during an Atlas scan.
//
// Contributions can be discovered by ID, concrete type, category, or source
// engine without requiring consumers to understand ScanSession internals.
class ContributionCollection {
  factory ContributionCollection({
    Iterable<IntelligenceContribution> contributions =
        const <IntelligenceContribution>[],
  }) {
    final Map<String, IntelligenceContribution> byId =
        <String, IntelligenceContribution>{};

    for (final IntelligenceContribution contribution in contributions) {
      final String contributionId = _normalizedContributionId(contribution);

      if (byId.containsKey(contributionId)) {
        throw StateError('Duplicate contribution ID: $contributionId');
      }

      byId[contributionId] = contribution;
    }

    return ContributionCollection._(
      Map<String, IntelligenceContribution>.unmodifiable(byId),
    );
  }

  const ContributionCollection._(this._byId);

  static final ContributionCollection empty = ContributionCollection();

  final Map<String, IntelligenceContribution> _byId;

  int get length {
    return _byId.length;
  }

  bool get isEmpty {
    return _byId.isEmpty;
  }

  bool get isNotEmpty {
    return _byId.isNotEmpty;
  }

  List<IntelligenceContribution> get values {
    return List<IntelligenceContribution>.unmodifiable(_byId.values);
  }

  bool containsId(String contributionId) {
    return _byId.containsKey(contributionId.trim());
  }

  IntelligenceContribution? contributionForId(String contributionId) {
    return _byId[contributionId.trim()];
  }

  T? contributionForIdAs<T extends IntelligenceContribution>(
    String contributionId,
  ) {
    final IntelligenceContribution? contribution = contributionForId(
      contributionId,
    );

    if (contribution is T) {
      return contribution;
    }

    return null;
  }

  List<T> ofType<T extends IntelligenceContribution>() {
    return List<T>.unmodifiable(_byId.values.whereType<T>());
  }

  T? latestOfType<T extends IntelligenceContribution>() {
    T? latest;

    for (final T contribution in _byId.values.whereType<T>()) {
      if (latest == null || contribution.createdAt.isAfter(latest.createdAt)) {
        latest = contribution;
      }
    }

    return latest;
  }

  List<IntelligenceContribution> forCategory(ContributionCategory category) {
    return List<IntelligenceContribution>.unmodifiable(
      _byId.values.where((IntelligenceContribution contribution) {
        return contribution.category == category;
      }),
    );
  }

  List<IntelligenceContribution> fromEngine(String engineId) {
    final String normalizedEngineId = engineId.trim();

    if (normalizedEngineId.isEmpty) {
      return const <IntelligenceContribution>[];
    }

    return List<IntelligenceContribution>.unmodifiable(
      _byId.values.where((IntelligenceContribution contribution) {
        return contribution.sourceEngineId == normalizedEngineId;
      }),
    );
  }

  List<IntelligenceContribution> withMinimumConfidence(
    double minimumConfidence,
  ) {
    final double normalizedMinimum =
        IntelligenceContributionValidation.normalizeConfidence(
          minimumConfidence,
        )!;

    return List<IntelligenceContribution>.unmodifiable(
      _byId.values.where((IntelligenceContribution contribution) {
        final double? confidence = contribution.confidence;

        return confidence != null && confidence >= normalizedMinimum;
      }),
    );
  }

  ContributionCollection add(
    IntelligenceContribution contribution, {
    ContributionConflictPolicy conflictPolicy =
        ContributionConflictPolicy.reject,
  }) {
    final String contributionId = _normalizedContributionId(contribution);

    final bool alreadyExists = _byId.containsKey(contributionId);

    if (alreadyExists) {
      switch (conflictPolicy) {
        case ContributionConflictPolicy.reject:
          throw StateError(
            'Contribution "$contributionId" '
            'already exists.',
          );

        case ContributionConflictPolicy.keepExisting:
          return this;

        case ContributionConflictPolicy.replaceExisting:
          break;
      }
    }

    return ContributionCollection(
      contributions: <IntelligenceContribution>[
        ..._byId.values.where((IntelligenceContribution existing) {
          return existing.contributionId.trim() != contributionId;
        }),
        contribution,
      ],
    );
  }

  ContributionCollection addAll(
    Iterable<IntelligenceContribution> contributions, {
    ContributionConflictPolicy conflictPolicy =
        ContributionConflictPolicy.reject,
  }) {
    ContributionCollection current = this;

    for (final IntelligenceContribution contribution in contributions) {
      current = current.add(contribution, conflictPolicy: conflictPolicy);
    }

    return current;
  }

  ContributionCollection removeById(String contributionId) {
    final String normalized = contributionId.trim();

    if (normalized.isEmpty || !_byId.containsKey(normalized)) {
      return this;
    }

    return ContributionCollection(
      contributions: _byId.values.where((
        IntelligenceContribution contribution,
      ) {
        return contribution.contributionId.trim() != normalized;
      }),
    );
  }

  ContributionCollection removeFromEngine(String engineId) {
    final String normalizedEngineId = engineId.trim();

    if (normalizedEngineId.isEmpty) {
      return this;
    }

    final List<IntelligenceContribution> remaining = _byId.values
        .where((IntelligenceContribution contribution) {
          return contribution.sourceEngineId != normalizedEngineId;
        })
        .toList(growable: false);

    if (remaining.length == length) {
      return this;
    }

    return ContributionCollection(contributions: remaining);
  }

  ContributionCollection removeCategory(ContributionCategory category) {
    final List<IntelligenceContribution> remaining = _byId.values
        .where((IntelligenceContribution contribution) {
          return contribution.category != category;
        })
        .toList(growable: false);

    if (remaining.length == length) {
      return this;
    }

    return ContributionCollection(contributions: remaining);
  }

  static String _normalizedContributionId(
    IntelligenceContribution contribution,
  ) {
    return IntelligenceContributionValidation.requireIdentifier(
      contribution.contributionId,
      fieldName: 'contributionId',
    );
  }

  @override
  String toString() {
    return 'ContributionCollection('
        'length: $length'
        ')';
  }
}
