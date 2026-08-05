import 'package:flutter/foundation.dart';

import '../../collection/actions/atlas_collector_action.dart';
import '../../collection/models/atlas_collector_state.dart';
import '../../intelligence/models/atlas_collector_summary.dart';
import 'atlas_scan_intelligence.dart';

@immutable
class AtlasCollectorInsight {
  const AtlasCollectorInsight({
    required this.state,
    required this.summary,
    required this.intelligence,
    this.actions = const <AtlasCollectorAction>[],
    this.generatedAt,
    this.confidence = 1.0,
    this.source = 'Atlas',
    this.diagnostics = const <String>[],
  });

  final AtlasCollectorState state;

  final AtlasCollectorSummary summary;

  final AtlasScanIntelligence intelligence;

  final List<AtlasCollectorAction> actions;

  final DateTime? generatedAt;

  final double confidence;

  final String source;

  final List<String> diagnostics;

  bool get isOwned {
    return state.isOwned;
  }

  bool get isWishlisted {
    return state.isWishlisted;
  }

  bool get hasRelatedVariants {
    return state.hasRelatedMatches;
  }

  bool get hasActions {
    return actions.isNotEmpty;
  }

  bool get hasDiagnostics {
    return diagnostics.isNotEmpty;
  }

  int get ownedQuantity {
    return state.ownedQuantity;
  }

  AtlasCollectorInsight copyWith({
    AtlasCollectorState? state,
    AtlasCollectorSummary? summary,
    AtlasScanIntelligence? intelligence,
    List<AtlasCollectorAction>? actions,
    DateTime? generatedAt,
    double? confidence,
    String? source,
    List<String>? diagnostics,
  }) {
    return AtlasCollectorInsight(
      state: state ?? this.state,
      summary: summary ?? this.summary,
      intelligence: intelligence ?? this.intelligence,
      actions: actions ?? this.actions,
      generatedAt: generatedAt ?? this.generatedAt,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      diagnostics: diagnostics ?? this.diagnostics,
    );
  }

  @override
  bool operator ==(
      Object other,
      ) {
    return identical(
      this,
      other,
    ) ||
        other is AtlasCollectorInsight &&
            runtimeType == other.runtimeType &&
            state == other.state &&
            summary == other.summary &&
            intelligence == other.intelligence &&
            listEquals(
              actions,
              other.actions,
            ) &&
            generatedAt == other.generatedAt &&
            confidence == other.confidence &&
            source == other.source &&
            listEquals(
              diagnostics,
              other.diagnostics,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      state,
      summary,
      intelligence,
      Object.hashAll(
        actions,
      ),
      generatedAt,
      confidence,
      source,
      Object.hashAll(
        diagnostics,
      ),
    );
  }

  @override
  String toString() {
    return 'AtlasCollectorInsight('
        'owned: $isOwned, '
        'wishlist: $isWishlisted, '
        'actions: ${actions.length}, '
        'confidence: $confidence'
        ')';
  }
}