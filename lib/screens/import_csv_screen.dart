import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pop.dart';
import '../services/app_state.dart';
import '../services/csv_import_service.dart';

class ImportCsvScreen extends StatefulWidget {
  const ImportCsvScreen({super.key});

  @override
  State<ImportCsvScreen> createState() =>
      _ImportCsvScreenState();
}

class _ImportCsvScreenState
    extends State<ImportCsvScreen> {
  String? _fileName;

  List<Pop> _importedPops = [];

  bool _loading = false;

  Future<void> _selectCsv() async {
    try {
      const XTypeGroup csvType = XTypeGroup(
        label: 'CSV',
        extensions: ['csv'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: [csvType],
      );

      if (file == null) {
        return;
      }

      setState(() {
        _loading = true;
      });

      final csvContent =
      await File(file.path).readAsString();

      final pops =
      CsvImportService.importCsv(
        csvContent,
      );

      setState(() {
        _fileName = file.name;
        _importedPops = pops;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Import failed: $e',
          ),
        ),
      );
    }
  }

  Future<void> _importCollection() async {
    if (_importedPops.isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
    });

    await context
        .read<AppState>()
        .importPops(_importedPops);

    setState(() {
      _loading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${_importedPops.length} Pops imported successfully!',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Import Collection CSV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.upload_file,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Import HobbyDB Collection',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                      textAlign:
                      TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Select your HobbyDB CSV export.',
                      textAlign:
                      TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed:
                      _loading
                          ? null
                          : _selectCsv,
                      icon: const Icon(
                        Icons.upload,
                      ),
                      label: const Text(
                        'Choose CSV File',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_loading)
              const Center(
                child:
                CircularProgressIndicator(),
              ),

            if (_fileName != null)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.description,
                  ),
                  title: Text(_fileName!),
                  subtitle: Text(
                    '${_importedPops.length} Pops Found',
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (_importedPops.isNotEmpty)
              ElevatedButton.icon(
                onPressed:
                _loading
                    ? null
                    : _importCollection,
                icon: const Icon(
                  Icons.download,
                ),
                label: Text(
                  'Import ${_importedPops.length} Pops',
                ),
              ),
          ],
        ),
      ),
    );
  }
}