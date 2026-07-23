import '../../identity/profile/identity_profile.dart';
import '../record/knowledge_record.dart';

// Contains the identity profiles produced by one knowledge mapper.
//
// The result preserves source and mapper information so later Atlas
// engines can explain how an identity profile was constructed.
class KnowledgeMapperResult {
  KnowledgeMapperResult({
    required this.mapperId,
    required this.mapperName,
    required this.mapperVersion,
    required this.sourceRecord,
    required List<IdentityProfile> profiles,
    required this.confidence,
    List<String> notes = const <String>[],
    Map<String, String> metadata =
    const <String, String>{},
  })  : assert(
  confidence >= 0.0 && confidence <= 1.0,
  'Confidence must be between 0.0 and 1.0.',
  ),
        profiles = List<IdentityProfile>.unmodifiable(
          profiles,
        ),
        notes = List<String>.unmodifiable(notes),
        metadata = Map<String, String>.unmodifiable(
          metadata,
        );

  final String mapperId;

  final String mapperName;

  final String mapperVersion;

  // Original provider record used to produce the profiles.
  final KnowledgeRecord sourceRecord;

  // Identity profile candidates created from the source record.
  final List<IdentityProfile> profiles;

  // Confidence that the record was mapped correctly.
  final double confidence;

  final List<String> notes;

  final Map<String, String> metadata;

  bool get isEmpty => profiles.isEmpty;

  bool get isNotEmpty => profiles.isNotEmpty;

  bool get hasNotes => notes.isNotEmpty;

  int get profileCount => profiles.length;

  IdentityProfile? get singleProfile {
    if (profiles.length != 1) {
      return null;
    }

    return profiles.first;
  }

  KnowledgeMapperResult copyWith({
    String? mapperId,
    String? mapperName,
    String? mapperVersion,
    KnowledgeRecord? sourceRecord,
    List<IdentityProfile>? profiles,
    double? confidence,
    List<String>? notes,
    Map<String, String>? metadata,
  }) {
    return KnowledgeMapperResult(
      mapperId: mapperId ?? this.mapperId,
      mapperName: mapperName ?? this.mapperName,
      mapperVersion:
      mapperVersion ?? this.mapperVersion,
      sourceRecord:
      sourceRecord ?? this.sourceRecord,
      profiles: profiles ?? this.profiles,
      confidence: confidence ?? this.confidence,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'KnowledgeMapperResult('
        'mapperId: $mapperId, '
        'sourceRecord: ${sourceRecord.recordId}, '
        'profiles: ${profiles.length}, '
        'confidence: $confidence'
        ')';
  }
}