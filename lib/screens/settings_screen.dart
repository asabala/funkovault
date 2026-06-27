import 'package:flutter/material.dart';

import 'import_csv_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.upload_file,
            ),
            title: const Text(
              'Import Collection CSV',
            ),
            subtitle: const Text(
              'Import a HobbyDB export',
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const ImportCsvScreen(),
                ),
              );
            },
          ),

          const Divider(),

          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Funko Vault'),
            subtitle: Text('Version 1.0'),
          ),
        ],
      ),
    );
  }
}