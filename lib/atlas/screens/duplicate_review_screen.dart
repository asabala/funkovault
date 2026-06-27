import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../repositories/vault_repository.dart';

class DuplicateReviewScreen extends StatelessWidget {
  const DuplicateReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    const repository = VaultRepository();

    final duplicateGroups =
    repository.duplicatePopGroups(appState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplicate Pops'),
      ),
      body: duplicateGroups.isEmpty
          ? const Center(
        child: Text(
          'No duplicate Pops found.\nYour Vault looks clean.',
          textAlign: TextAlign.center,
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: duplicateGroups.length,
        separatorBuilder: (context, index) =>
        const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final group = duplicateGroups[index];
          final firstPop = group.first;

          return Card(
            child: ExpansionTile(
              leading: CircleAvatar(
                child: Text(group.length.toString()),
              ),
              title: Text(firstPop.name),
              subtitle: Text(
                'Pop #${firstPop.number} • ${firstPop.category}',
              ),
              children: group.map((pop) {
                return ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(pop.owner),
                  subtitle: Text(
                    'Value: \$${pop.value.toStringAsFixed(2)}',
                  ),
                  trailing: const Text('Keep'),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}