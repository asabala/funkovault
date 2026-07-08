import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../repositories/vault_repository.dart';
import '../../screens/pop/pop_details_screen.dart';

class MissingValuesScreen extends StatelessWidget {
  const MissingValuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();

    final pops = repository
        .allPops(appState)
        .where((pop) => pop.value <= 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missing Values'),
      ),
      body: pops.isEmpty
          ? const Center(
        child: Text(
          'No missing values found.\nYour Vault looks strong.',
          textAlign: TextAlign.center,
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: pops.length,
        separatorBuilder: (context, index) =>
        const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final pop = pops[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.sell),
              title: Text(pop.name),
              subtitle: Text(
                'Pop #${pop.number} • ${pop.collectorLabel}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PopDetailsScreen(pop: pop),
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