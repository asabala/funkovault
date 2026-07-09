import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../services/csv_import_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class ImportCsvScreen extends StatefulWidget {
  const ImportCsvScreen({super.key});

  @override
  State<ImportCsvScreen> createState() => _ImportCsvScreenState();
}

class _ImportCsvScreenState extends State<ImportCsvScreen> {
  final _csvController = TextEditingController();

  CsvImportParseResult? _parseResult;
  PopImportResult? _importResult;

  bool _isImporting = false;
  String? _selectedFileName;

  @override
  void dispose() {
    _csvController.dispose();

    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    const acceptedTypes = [
      XTypeGroup(
        label: 'CSV files',
        extensions: [
          'csv',
          'txt',
          'tsv',
        ],
      ),
    ];

    final file = await openFile(
      acceptedTypeGroups: acceptedTypes,
    );

    if (file == null) {
      return;
    }

    final content = await file.readAsString();

    _csvController.text = content;

    final result = const CsvImportService().parsePops(content);

    setState(() {
      _selectedFileName = file.name;
      _parseResult = result;
      _importResult = null;
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Loaded ${file.name}. Preview parsed ${result.parsedRows} Pop${result.parsedRows == 1 ? '' : 's'}.',
        ),
      ),
    );
  }

  void _previewCsv() {
    final rawContent = _csvController.text.trim();

    if (rawContent.isEmpty) {
      setState(() {
        _parseResult = const CsvImportParseResult(
          pops: [],
          skippedRows: 0,
          errors: ['Paste or upload your CSV or tab-separated export first.'],
        );
        _importResult = null;
      });

      return;
    }

    final result = const CsvImportService().parsePops(rawContent);

    setState(() {
      _parseResult = result;
      _importResult = null;
    });
  }

  Future<void> _importCsv() async {
    final rawContent = _csvController.text.trim();

    if (rawContent.isEmpty) {
      _previewCsv();
      return;
    }

    setState(() {
      _isImporting = true;
      _importResult = null;
    });

    try {
      final parseResult = const CsvImportService().parsePops(rawContent);

      if (parseResult.pops.isEmpty) {
        setState(() {
          _parseResult = parseResult;
        });

        return;
      }

      final importResult = await context.read<AppState>().importPopsSafely(
        parseResult.pops,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _parseResult = parseResult;
        _importResult = importResult;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Import complete: ${importResult.added} added, ${importResult.skipped} skipped.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  void _clearCsv() {
    _csvController.clear();

    setState(() {
      _selectedFileName = null;
      _parseResult = null;
      _importResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import CSV'),
      ),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CSV Import',
                  style: AtlasTypography.headingLarge,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Upload or paste your HobbyDB export. Atlas will preview it first, then import only new Pops and skip duplicates.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                OutlinedButton.icon(
                  onPressed: _isImporting ? null : _pickCsvFile,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Upload CSV File'),
                ),
                if (_selectedFileName != null) ...[
                  const SizedBox(height: AtlasSpacing.sm),
                  Text(
                    'Selected file: $_selectedFileName',
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AtlasSpacing.lg),
                TextField(
                  controller: _csvController,
                  minLines: 8,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    hintText: 'Or paste CSV / tab-separated export here...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AtlasSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isImporting ? null : _previewCsv,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Preview'),
                      ),
                    ),
                    const SizedBox(width: AtlasSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isImporting ? null : _importCsv,
                        icon: _isImporting
                            ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(Icons.upload_file_rounded),
                        label: Text(_isImporting ? 'Importing' : 'Import'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AtlasSpacing.sm),
                TextButton.icon(
                  onPressed: _isImporting ? null : _clearCsv,
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          if (_parseResult != null)
            _CsvPreviewCard(
              result: _parseResult!,
            ),
          if (_importResult != null) ...[
            const SizedBox(height: AtlasSpacing.lg),
            _CsvImportResultCard(
              result: _importResult!,
            ),
          ],
        ],
      ),
    );
  }
}

class _CsvPreviewCard extends StatelessWidget {
  const _CsvPreviewCard({
    required this.result,
  });

  final CsvImportParseResult result;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import Preview',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreviewLine(
                  label: 'Parsed Pops',
                  value: '${result.parsedRows}',
                ),
                _PreviewLine(
                  label: 'Skipped Rows',
                  value: '${result.skippedRows}',
                ),
                _PreviewLine(
                  label: 'Issues',
                  value: '${result.errors.length}',
                ),
              ],
            ),
          ),
          if (result.errors.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.md),
            Text(
              'Issues Found',
              style: AtlasTypography.headingSmall,
            ),
            const SizedBox(height: AtlasSpacing.sm),
            ...result.errors.take(5).map(
                  (error) => Padding(
                padding: const EdgeInsets.only(bottom: AtlasSpacing.xs),
                child: Text(
                  error,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CsvImportResultCard extends StatelessWidget {
  const _CsvImportResultCard({
    required this.result,
  });

  final PopImportResult result;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import Complete',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreviewLine(
                  label: 'Attempted',
                  value: '${result.attempted}',
                ),
                _PreviewLine(
                  label: 'Added',
                  value: '${result.added}',
                ),
                _PreviewLine(
                  label: 'Duplicates Skipped',
                  value: '${result.skipped}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AtlasSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AtlasTypography.bodyMedium.copyWith(
                color: AtlasColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}