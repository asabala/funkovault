import 'package:flutter/material.dart';

import '../tasks/atlas_task.dart';
import 'duplicate_review_screen.dart';

class VaultTasksScreen extends StatelessWidget {
  const VaultTasksScreen({super.key, required this.tasks});

  final List<AtlasTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vault Tasks')),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'No Vault Tasks found.\nYour Vault looks good.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(task.count.toString())),
                    title: Text(task.title),
                    subtitle: Text(task.description),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      if (task.id == 'duplicates') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DuplicateReviewScreen(),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${task.actionText} coming soon.'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
