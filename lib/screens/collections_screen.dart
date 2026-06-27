import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'collection_details_screen.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  void _showCreateCollectionDialog(
      BuildContext context,
      AppState appState,
      ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Create Collection'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Collection Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) return;

                appState.addCollection(name);

                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCollectionDialog(
      BuildContext context,
      AppState appState,
      String collectionName,
      ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Collection'),
          content: Text(
            'Are you sure you want to delete "$collectionName"?\n\n'
                'All Pops in this collection will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                appState.deleteCollection(
                  collectionName,
                );

                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: appState.selectedCollection,
              decoration: const InputDecoration(
                labelText: 'Currently Viewing',
                border: OutlineInputBorder(),
              ),
              items: appState.collectionNames.map((name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  appState.setSelectedCollection(value);
                }
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: appState.collectionNames.length,
                itemBuilder: (context, index) {
                  final collectionName =
                  appState.collectionNames[index];

                  final popCount =
                  appState.collectionPopCount(
                    collectionName,
                  );

                  final collectionValue =
                  appState.collectionValue(
                    collectionName,
                  );

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.folder),
                      ),
                      title: Text(collectionName),
                      subtitle: Text(
                        '$popCount Pops • \$${collectionValue.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (appState
                              .collectionNames.length >
                              1)
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Delete Collection',
                              onPressed: () {
                                _showDeleteCollectionDialog(
                                  context,
                                  appState,
                                  collectionName,
                                );
                              },
                            ),
                          const Icon(
                            Icons.chevron_right,
                          ),
                        ],
                      ),
                      onTap: () {
                        appState.setSelectedCollection(
                          collectionName,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CollectionDetailsScreen(
                                  collectionName:
                                  collectionName,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showCreateCollectionDialog(
                      context,
                      appState,
                    ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Create Collection',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}