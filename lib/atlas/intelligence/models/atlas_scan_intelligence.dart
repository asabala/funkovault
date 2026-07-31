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
enum AtlasScanInsightPriority {
  low,
  normal,
  high,
  critical,
}

/// One immutable intelligence insight produced from a scan session.
@immutable
class AtlasScanInsight {
  const AtlasScanInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.priority = AtlasScanInsightPriority.normal,
    this.details = const <String>[],
    this.recommendation,
  });

  final String id;

  final AtlasScanInsightType type;

  final String title;

  final String message;

  final AtlasScanInsightPriority priority;

  final List<String> details;

  final String? recommendation;

  bool get hasDetails {
    return details.isNotEmpty;
  }

  bool get hasRecommendation {
    return recommendation?.trim().isNotEmpty ?? false;
  }

  AtlasScanInsight copyWith({
    String? id,
    AtlasScanInsightType? type,
    String? title,
    String? message,
    AtlasScanInsightPriority? priority,
    List<String>? details,
    String? recommendation,
  }) {
    return AtlasScanInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      details: details ?? this.details,
      recommendation: recommendation ?? this.recommendation,
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
            priority == other.priority &&
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
      priority,
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

  factory AtlasScanIntelligence.empty({
    required String sessionId,
  }) {
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
    return insights.any(
          (AtlasScanInsight insight) {
        return insight.priority == AtlasScanInsightPriority.high ||
            insight.priority == AtlasScanInsightPriority.critical;
      },
    );
  }

  List<AtlasScanInsight> get recommendations {
    return List<AtlasScanInsight>.unmodifiable(
      insights.where(
            (AtlasScanInsight insight) {
          return insight.type == AtlasScanInsightType.recommendation ||
              insight.hasRecommendation;
        },
      ),
    );
  }

  List<AtlasScanInsight> insightsOfType(
      AtlasScanInsightType type,
      ) {
    return List<AtlasScanInsight>.unmodifiable(
      insights.where(
            (AtlasScanInsight insight) {
          return insight.type == type;
        },
      ),
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
    return Object.hash(
      sessionId,
      generatedAt,
      Object.hashAll(insights),
    );
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