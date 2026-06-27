import 'package:flutter/material.dart';

import '../models/atlas_response.dart';
import '../services/atlas_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  final TextEditingController _commandController =
  TextEditingController();

  AtlasResponse? _lastResponse;
  bool _isProcessing = false;

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  Future<void> _runAtlasCommand() async {
    final command =
    _commandController.text.trim();

    if (command.isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final response =
    await AtlasService.instance.ask(command);

    setState(() {
      _lastResponse = response;
      _isProcessing = false;
    });

    _commandController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Appearance'),
              subtitle: const Text('Dark theme enabled'),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '🛡️ Atlas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          FutureBuilder<String>(
            future: AtlasService.instance.status(),
            builder: (context, snapshot) {
              final status =
                  snapshot.data ?? 'Checking Atlas...';

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.shield),
                  title: Text(status),
                  subtitle: const Text(
                    'Atlas is the intelligence engine behind Funko Vault.',
                  ),
                ),
              );
            },
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              subtitle: const Text(AtlasService.version),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text('Motto'),
              subtitle: const Text(AtlasService.motto),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Atlas Console',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _commandController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Ask Atlas',
                      hintText: 'Try: status, version, motto, help',
                      prefixIcon: Icon(Icons.terminal),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      _runAtlasCommand();
                    },
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : _runAtlasCommand,
                      icon: const Icon(Icons.shield),
                      label: Text(
                        _isProcessing
                            ? 'Atlas is thinking...'
                            : 'Run Command',
                      ),
                    ),
                  ),

                  if (_lastResponse != null) ...[
                    const SizedBox(height: 16),
                    _AtlasResponseCard(
                      response: _lastResponse!,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          Center(
            child: Text(
              '🛡️ Powered by Atlas',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              AtlasService.version,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtlasResponseCard extends StatelessWidget {
  const _AtlasResponseCard({
    required this.response,
  });

  final AtlasResponse response;

  @override
  Widget build(BuildContext context) {
    final title =
        response.title ?? 'Atlas Response';

    final message =
        response.message;

    final suggestedAction =
        response.suggestedAction;

    return Card(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(message),

            if (suggestedAction != null) ...[
              const SizedBox(height: 12),
              Text(
                suggestedAction,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}