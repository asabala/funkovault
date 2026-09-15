import '../record/knowledge_record.dart';

// Contains knowledge records returned by one provider.
//
// Results remain source-specific so a future resolver can evaluate
// provenance, confidence, conflicts, and supporting evidence.
class KnowledgeProviderResult {
  KnowledgeProviderResult({
    required this.providerId,
    required this.providerName,
    required this.providerVersion,
    required List<KnowledgeRecord> records,
    required this.confidence,
    required this.startedAt,
    required this.completedAt,
    List<String> notes = const <String>[],
    Map<String, String> metadata = const <String, String>{},
  }) : assert(
         confidence >= 0.0 && confidence <= 1.0,
         'Confidence must be between 0.0 and 1.0.',
       ),
       records = List<KnowledgeRecord>.unmodifiable(records),
       notes = List<String>.unmodifiable(notes),
       metadata = Map<String, String>.unmodifiable(metadata);

  final String providerId;

  final String providerName;

  final String providerVersion;

  // Source records discovered by this provider.
  final List<KnowledgeRecord> records;

  // Provider-level confidence in the returned information.
  final double confidence;

  final DateTime startedAt;

  final DateTime completedAt;

  final List<String> notes;

  final Map<String, String> metadata;

  bool get isEmpty => records.isEmpty;

  bool get isNotEmpty => records.isNotEmpty;

  bool get hasNotes => notes.isNotEmpty;

  int get recordCount => records.length;

  Duration get executionDuration {
    return completedAt.difference(startedAt);
  }

  KnowledgeRecord? recordById(String recordId) {
    final String normalizedId = recordId.trim();

    for (final KnowledgeRecord record in records) {
      if (record.recordId == normalizedId) {
        return record;
      }
    }

    return null;
  }

  KnowledgeProviderResult copyWith({
    String? providerId,
    String? providerName,
    String? providerVersion,
    List<KnowledgeRecord>? records,
    double? confidence,
    DateTime? startedAt,
    DateTime? completedAt,
    List<String>? notes,
    Map<String, String>? metadata,
  }) {
    return KnowledgeProviderResult(
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerVersion: providerVersion ?? this.providerVersion,
      records: records ?? this.records,
      confidence: confidence ?? this.confidence,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'KnowledgeProviderResult('
        'providerId: $providerId, '
        'records: ${records.length}, '
        'confidence: $confidence, '
        'duration: $executionDuration'
        ')';
  }
}
