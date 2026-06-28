import '../models/atlas_activity.dart';

class AtlasActivityService {
  const AtlasActivityService();

  static final List<AtlasActivity> _activities = [
    AtlasActivity(
      title: 'Atlas Timeline Online',
      description:
      'Atlas is ready to track important Vault activity.',
      timestamp: DateTime.now(),
      type: 'system',
    ),
  ];

  List<AtlasActivity> recentActivities() {
    return List.unmodifiable(_activities);
  }

  static void record({
    required String title,
    required String description,
    required String type,
  }) {
    _activities.insert(
      0,
      AtlasActivity(
        title: title,
        description: description,
        timestamp: DateTime.now(),
        type: type,
      ),
    );
  }
}