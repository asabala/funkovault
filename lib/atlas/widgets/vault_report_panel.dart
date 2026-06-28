import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../intelligence/vault_intelligence.dart';
import '../repositories/vault_repository.dart';
import '../screens/vault_tasks_screen.dart';
import '../tasks/atlas_task_engine.dart';

class VaultReportPanel extends StatelessWidget {
  const VaultReportPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    const repository = VaultRepository();
    const intelligence = VaultIntelligence();
    const taskEngine = AtlasTaskEngine();

    final allPops = repository.allPops(appState);

    final duplicateCount =
        repository.duplicatePopGroups(appState).length;

    final missingValueCount = allPops
        .where((pop) => pop.value <= 0)
        .length;

    const missingPurchaseDateCount = 0;

    String largestCollectionName = '';
    int largestCollectionCount = 0;

    for (final entry in appState.collections.entries) {
      if (entry.value.length > largestCollectionCount) {
        largestCollectionName = entry.key;
        largestCollectionCount = entry.value.length;
      }
    }

    final report = intelligence.generateReport(
      totalPops: repository.totalPops(appState),
      totalCollections: appState.collections.length,
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
      missingPurchaseDateCount: missingPurchaseDateCount,
      largestCollectionName: largestCollectionName,
      largestCollectionCount: largestCollectionCount,
    );

    final tasks = taskEngine.buildTasks(
      duplicateCount: duplicateCount,
      missingValueCount: missingValueCount,
      missingPurchaseDateCount: missingPurchaseDateCount,
    );

    final primaryTask =
    taskEngine.highestPriority(tasks);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              '🛡️ Vault Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              primaryTask?.title ?? report.reportTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              primaryTask?.description ??
                  report.reportMessage,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Vault Health',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${report.formattedHealthScore} • ${report.healthLabel}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.task_alt),
                  label: Text(
                    tasks.length == 1
                        ? primaryTask!.actionText
                        : 'Review ${tasks.length} Vault Tasks',
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VaultTasksScreen(tasks: tasks),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}