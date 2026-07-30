import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';

class AtlasTimelineFactory {
  const AtlasTimelineFactory._();

  static AtlasTimelineEvent addedToVault({
    required String id,
    required String popId,
    required DateTime occurredAt,
  }) {
    return AtlasTimelineEvent(
      id: id,
      popId: popId,
      type: AtlasTimelineEventType.addedToVault,
      occurredAt: occurredAt,
      title: 'Added to Vault',
      createdBy: AtlasTimelineEvent.systemCreatedBy,
    );
  }

  static AtlasTimelineEvent valueUpdated({
    required String id,
    required String popId,
    required DateTime occurredAt,
    required double previousValue,
    required double newValue,
    required String source,
  }) {
    final change = newValue - previousValue;

    return AtlasTimelineEvent(
      id: id,
      popId: popId,
      type: AtlasTimelineEventType.valueUpdated,
      occurredAt: occurredAt,
      title: 'Value Updated',
      description:
      '\$${previousValue.toStringAsFixed(2)} → \$${newValue.toStringAsFixed(2)}',
      createdBy: AtlasTimelineEvent.systemCreatedBy,
      metadata: {
        'previousValue': previousValue,
        'newValue': newValue,
        'change': change,
        'changeDirection': change >= 0 ? 'increase' : 'decrease',
        'source': source,
      },
    );
  }

  static AtlasTimelineEvent collectorMoment({
    required String id,
    required String popId,
    required DateTime occurredAt,
    required String title,
    String description = '',
  }) {
    return AtlasTimelineEvent(
      id: id,
      popId: popId,
      type: AtlasTimelineEventType.collectorMoment,
      occurredAt: occurredAt,
      title: title,
      description: description,
      createdBy: AtlasTimelineEvent.manualCreatedBy,
    );
  }

  static AtlasTimelineEvent custom({
    required String id,
    required String popId,
    required DateTime occurredAt,
    required String title,
    String description = '',
    Map<String, dynamic> metadata = const {},
  }) {
    return AtlasTimelineEvent(
      id: id,
      popId: popId,
      type: AtlasTimelineEventType.custom,
      occurredAt: occurredAt,
      title: title,
      description: description,
      metadata: metadata,
      createdBy: AtlasTimelineEvent.manualCreatedBy,
    );
  }
}