import 'package:flutter/foundation.dart';

/// The category of intelligence Atlas produced for a scan.
enum AtlasScanInsightType {
  identity,
  collection,
  variant,
  market,
  recommendation,
  warning,
}

/// The importance of an Atlas scan insight.
enum AtlasScanInsightPriority { low, normal, high, critical }

/// Identifies the system that produced an Atlas insight.
enum AtlasScanInsightSource {
  scan,
  identity,
  collection,
  market,
  recommendation,
  system,
}

/// One immutable intelligence insight produced from a scan session.
@immutable
class AtlasScanInsight {
  const AtlasScanInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.emoji = '🧠',
    this.priority = AtlasScanInsightPriority.normal,
    this.priorityWeight,
    this.source = AtlasScanInsightSource.scan,
    this.requiresOnline = false,
    this.details = const <String>[],
    this.recommendation,
  });

  final String id;

  final AtlasScanInsightType type;

  final String title;

  final String message;

  /// Collector-facing visual identifier.
  final String emoji;

  /// Optional explicit sorting weight.
  ///
  /// Lower values represent more important insights.
  final int? priorityWeight;

  /// System that produced this insight.
  final AtlasScanInsightSource source;

  /// Whether connected services are required to refresh this insight.
  final bool requiresOnline;

  final AtlasScanInsightPriority priority;

  final List<String> details;

  final String? recommendation;

  bool get hasDetails {
    return details.isNotEmpty;
  }

  bool get hasRecommendation {
    return recommendation?.trim().isNotEmpty ?? false;
  }

  int get effectivePriorityWeight {
    final int? explicitWeight = priorityWeight;

    if (explicitWeight != null) {
      return explicitWeight.clamp(1, 100);
    }

    switch (priority) {
      case AtlasScanInsightPriority.critical:
        return 5;

      case AtlasScanInsightPriority.high:
        return 20;

      case AtlasScanInsightPriority.normal:
        return 50;

      case AtlasScanInsightPriority.low:
        return 80;
    }
  }

  String get displayTitle {
    final String normalizedEmoji = emoji.trim();
    final String normalizedTitle = title.trim();

    if (normalizedEmoji.isEmpty) {
      return normalizedTitle;
    }

    return '$normalizedEmoji $normalizedTitle';
  }

  bool get isOfflineSafe {
    return !requiresOnline;
  }

  bool get isCompactDisplayCandidate {
    return effectivePriorityWeight <= 50;
  }

  AtlasScanInsight copyWith({
    String? id,
    AtlasScanInsightType? type,
    String? title,
    String? message,
    AtlasScanInsightPriority? priority,
    List<String>? details,
    String? recommendation,
    String? emoji,
    int? priorityWeight,
    AtlasScanInsightSource? source,
    bool? requiresOnline,
  }) {
    return AtlasScanInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      details: details ?? this.details,
      recommendation: recommendation ?? this.recommendation,
      emoji: emoji ?? this.emoji,
      priorityWeight: priorityWeight ?? this.priorityWeight,
      source: source ?? this.source,
      requiresOnline: requiresOnline ?? this.requiresOnline,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AtlasScanInsight &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            type == other.type &&
            title == other.title &&
            message == other.message &&
            emoji == other.emoji &&
            priority == other.priority &&
            priorityWeight == other.priorityWeight &&
            source == other.source &&
            requiresOnline == other.requiresOnline &&
            listEquals(details, other.details) &&
            recommendation == other.recommendation;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      title,
      message,
      emoji,
      priority,
      priorityWeight,
      source,
      requiresOnline,
      Object.hashAll(details),
      recommendation,
    );
  }

  @override
  String toString() {
    return 'AtlasScanInsight('
        'id: $id, '
        'type: ${type.name}, '
        'priority: ${priority.name}, '
        'priorityWeight: $effectivePriorityWeight, '
        'source: ${source.name}, '
        'requiresOnline: $requiresOnline, '
        'title: $title'
        ')';
  }
}

/// Complete immutable intelligence output for one scan session.
@immutable
class AtlasScanIntelligence {
  AtlasScanIntelligence({
    required this.sessionId,
    required this.generatedAt,
    List<AtlasScanInsight> insights = const <AtlasScanInsight>[],
  }) : insights = List<AtlasScanInsight>.unmodifiable(insights);

  factory AtlasScanIntelligence.empty({required String sessionId}) {
    return AtlasScanIntelligence(
      sessionId: sessionId,
      generatedAt: DateTime.now(),
    );
  }

  final String sessionId;

  final DateTime generatedAt;

  final List<AtlasScanInsight> insights;

  bool get isEmpty {
    return insights.isEmpty;
  }

  bool get isNotEmpty {
    return insights.isNotEmpty;
  }

  int get insightCount {
    return insights.length;
  }

  bool get hasHighPriorityInsights {
    return insights.any((AtlasScanInsight insight) {
      return insight.priority == AtlasScanInsightPriority.high ||
          insight.priority == AtlasScanInsightPriority.critical;
    });
  }

  List<AtlasScanInsight> get recommendations {
    return List<AtlasScanInsight>.unmodifiable(
      insights.where((AtlasScanInsight insight) {
        return insight.type == AtlasScanInsightType.recommendation ||
            insight.hasRecommendation;
      }),
    );
  }

  List<AtlasScanInsight> insightsOfType(AtlasScanInsightType type) {
    return List<AtlasScanInsight>.unmodifiable(
      insights.where((AtlasScanInsight insight) {
        return insight.type == type;
      }),
    );
  }

  AtlasScanIntelligence copyWith({
    String? sessionId,
    DateTime? generatedAt,
    List<AtlasScanInsight>? insights,
  }) {
    return AtlasScanIntelligence(
      sessionId: sessionId ?? this.sessionId,
      generatedAt: generatedAt ?? this.generatedAt,
      insights: insights ?? this.insights,
    );
  }

  List<AtlasScanInsight> get prioritizedInsights {
    final List<AtlasScanInsight> sorted = List<AtlasScanInsight>.from(insights);

    sorted.sort((AtlasScanInsight first, AtlasScanInsight second) {
      return first.effectivePriorityWeight.compareTo(
        second.effectivePriorityWeight,
      );
    });

    return List<AtlasScanInsight>.unmodifiable(sorted);
  }

  List<AtlasScanInsight> topInsights({int limit = 3}) {
    if (limit <= 0) {
      return const <AtlasScanInsight>[];
    }

    return List<AtlasScanInsight>.unmodifiable(prioritizedInsights.take(limit));
  }

  List<AtlasScanInsight> compactInsights({int limit = 3}) {
    if (limit <= 0) {
      return const <AtlasScanInsight>[];
    }

    return List<AtlasScanInsight>.unmodifiable(
      prioritizedInsights
          .where((AtlasScanInsight insight) {
            return insight.isCompactDisplayCandidate;
          })
          .take(limit),
    );
  }

  List<AtlasScanInsight> get offlineInsights {
    return List<AtlasScanInsight>.unmodifiable(
      prioritizedInsights.where((AtlasScanInsight insight) {
        return insight.isOfflineSafe;
      }),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AtlasScanIntelligence &&
            runtimeType == other.runtimeType &&
            sessionId == other.sessionId &&
            generatedAt == other.generatedAt &&
            listEquals(insights, other.insights);
  }

  @override
  int get hashCode {
    return Object.hash(sessionId, generatedAt, Object.hashAll(insights));
  }

  @override
  String toString() {
    return 'AtlasScanIntelligence('
        'sessionId: $sessionId, '
        'insights: ${insights.length}, '
        'generatedAt: $generatedAt'
        ')';
  }
}
