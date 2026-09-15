import '../data/academy_request_table.dart';

enum AcademyRequestType { topic, track }

enum AcademyRequestStatus { newRequest, reviewed, approved, declined }

class AcademyRequest {
  AcademyRequest({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
    this.description = '',
    this.source = 'Atlas Academy',
    this.notes = '',
    this.trackId,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  final String id;
  final String title;
  final String description;
  final AcademyRequestType type;
  final AcademyRequestStatus status;
  final String source;
  final String notes;
  final String? trackId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isNew {
    return status == AcademyRequestStatus.newRequest;
  }

  bool get isTopicRequest {
    return type == AcademyRequestType.topic;
  }

  bool get isTrackRequest {
    return type == AcademyRequestType.track;
  }

  String get typeLabel {
    switch (type) {
      case AcademyRequestType.topic:
        return 'Topic Request';
      case AcademyRequestType.track:
        return 'Track Request';
    }
  }

  String get statusLabel {
    switch (status) {
      case AcademyRequestStatus.newRequest:
        return 'New';
      case AcademyRequestStatus.reviewed:
        return 'Reviewed';
      case AcademyRequestStatus.approved:
        return 'Approved';
      case AcademyRequestStatus.declined:
        return 'Declined';
    }
  }

  AcademyRequest copyWith({
    String? id,
    String? title,
    String? description,
    AcademyRequestType? type,
    AcademyRequestStatus? status,
    String? source,
    String? notes,
    String? trackId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AcademyRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      trackId: trackId ?? this.trackId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AcademyRequestTable.id: id,
      AcademyRequestTable.title: title,
      AcademyRequestTable.description: description,
      AcademyRequestTable.type: type.name,
      AcademyRequestTable.status: status.name,
      AcademyRequestTable.source: source,
      AcademyRequestTable.notes: notes,
      AcademyRequestTable.trackId: trackId,
      AcademyRequestTable.createdAt: createdAt.toIso8601String(),
      AcademyRequestTable.updatedAt: updatedAt.toIso8601String(),
    };
  }

  factory AcademyRequest.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.parse(
      map[AcademyRequestTable.createdAt] as String,
    );

    return AcademyRequest(
      id: map[AcademyRequestTable.id] as String,
      title: map[AcademyRequestTable.title] as String,
      description: map[AcademyRequestTable.description] as String? ?? '',
      type: AcademyRequestType.values.byName(
        map[AcademyRequestTable.type] as String,
      ),
      status: AcademyRequestStatus.values.byName(
        map[AcademyRequestTable.status] as String,
      ),
      source: map[AcademyRequestTable.source] as String? ?? 'Atlas Academy',
      notes: map[AcademyRequestTable.notes] as String? ?? '',
      trackId: map[AcademyRequestTable.trackId] as String?,
      createdAt: createdAt,
      updatedAt: map[AcademyRequestTable.updatedAt] == null
          ? createdAt
          : DateTime.parse(map[AcademyRequestTable.updatedAt] as String),
    );
  }
}
