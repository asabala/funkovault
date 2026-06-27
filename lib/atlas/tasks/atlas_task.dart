import 'atlas_task_priority.dart';
import 'atlas_task_type.dart';

class AtlasTask {
  const AtlasTask({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.actionText,
    required this.count,
  });

  final String id;
  final AtlasTaskType type;
  final AtlasTaskPriority priority;
  final String title;
  final String description;
  final String actionText;
  final int count;

  bool get hasItems => count > 0;
}