import 'atlas_task.dart';
import 'atlas_task_priority.dart';
import 'atlas_task_type.dart';

class AtlasTaskEngine {
  const AtlasTaskEngine();

  List<AtlasTask> buildTasks({
    required int duplicateCount,
    required int missingValueCount,
    required int missingPurchaseDateCount,
  }) {
    final tasks = <AtlasTask>[];

    if (duplicateCount > 0) {
      tasks.add(
        AtlasTask(
          id: 'duplicates',
          type: AtlasTaskType.duplicates,
          priority: AtlasTaskPriority.high,
          title: 'Review Duplicate Pops',
          description: '$duplicateCount possible duplicate Pops were found.',
          actionText: 'Review Duplicates',
          count: duplicateCount,
        ),
      );
    }

    if (missingValueCount > 0) {
      tasks.add(
        AtlasTask(
          id: 'values',
          type: AtlasTaskType.missingValues,
          priority: AtlasTaskPriority.medium,
          title: 'Missing Values',
          description: '$missingValueCount Pops are missing values.',
          actionText: 'Review Pops',
          count: missingValueCount,
        ),
      );
    }

    if (missingPurchaseDateCount > 0) {
      tasks.add(
        AtlasTask(
          id: 'dates',
          type: AtlasTaskType.missingPurchaseDates,
          priority: AtlasTaskPriority.low,
          title: 'Missing Purchase Dates',
          description: '$missingPurchaseDateCount Pops need purchase dates.',
          actionText: 'Complete Information',
          count: missingPurchaseDateCount,
        ),
      );
    }

    return tasks;
  }

  AtlasTask? highestPriority(List<AtlasTask> tasks) {
    if (tasks.isEmpty) return null;

    tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    return tasks.first;
  }
}
