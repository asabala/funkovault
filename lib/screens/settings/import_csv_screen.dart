import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../services/csv_import_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class ImportCsvScreen extends StatefulWidget {
  const ImportCsvScreen({super.key, this.collectionName});

  final String? collectionName;

  @override
  State<ImportCsvScreen> createState() {
    return _ImportCsvScreenState();
  }
}

class _ImportCsvScreenState extends State<ImportCsvScreen> {
  final TextEditingController _csvController = TextEditingController();

  CsvImportParseResult? _parseResult;
  PopImportResult? _importResult;

  bool _isImporting = false;
  String? _selectedFileName;
  String? _operationError;
  String? _capturedCollectionName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _capturedCollectionName ??=
        widget.collectionName ?? context.read<AppState>().selectedCollection;
  }

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    const acceptedTypes = [
      XTypeGroup(label: 'CSV files', extensions: ['csv', 'txt', 'tsv']),
    ];

    try {
      final file = await openFile(acceptedTypeGroups: acceptedTypes);

      if (file == null) {
        return;
      }

      final content = await file.readAsString();

      final result = const CsvImportService().parsePops(content);

      if (!mounted) {
        return;
      }

      _csvController.text = content;

      setState(() {
        _selectedFileName = file.name;
        _parseResult = result;
        _importResult = null;
        _operationError = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Loaded ${file.name}. Preview parsed '
            '${result.parsedRows} '
            'Pop${result.parsedRows == 1 ? '' : 's'}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _operationError =
            'Atlas could not read that file. Check the file and try again.';
        _importResult = null;
      });
    }
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
        _operationError = null;
      });

      return;
    }

    try {
      final result = const CsvImportService().parsePops(rawContent);

      setState(() {
        _parseResult = result;
        _importResult = null;
        _operationError = null;
      });
    } catch (error) {
      setState(() {
        _parseResult = null;
        _importResult = null;
        _operationError =
            'Atlas could not parse this import data. Check the file format and try again.';
      });
    }
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
      _operationError = null;
    });

    try {
      final parseResult = const CsvImportService().parsePops(rawContent);

      if (parseResult.pops.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _parseResult = parseResult;
        });

        return;
      }

      final importResult = await context.read<AppState>().importPopsSafely(
        parseResult.pops,
        collectionName: _capturedCollectionName,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _parseResult = parseResult;
        _importResult = importResult;
        _operationError = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Import complete: '
            '${importResult.added} unique records added, '
            '${importResult.skipped} matching copies consolidated.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _operationError =
            'Atlas could not complete the import. Your existing vault data was not intentionally cleared. Review the file and try again.';
      });
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
      _operationError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import CSV')),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            accentColor: AtlasColors.vaultGold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AtlasSectionHeader(
                  title: 'CSV Import',
                  subtitle:
                      'Upload or paste your HobbyDB export. Atlas will preview it first, add unique collectible records, and consolidate matching copies into quantity.',
                  icon: Icons.upload_file_rounded,
                  accentColor: AtlasColors.vaultGold,
                ),
                const SizedBox(height: AtlasSpacing.lg),
                const AtlasInfoBanner(
                  icon: Icons.content_copy_rounded,
                  title: 'Import Safety',
                  message:
                      'Atlas may consolidate records that represent matching physical copies. Variants, Chase versions, stickers, exclusives, limited editions, and signatures should remain distinct when their saved identity details differ.',
                ),
                const SizedBox(height: AtlasSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isImporting ? null : _pickCsvFile,
                    icon: const Icon(Icons.file_upload_outlined),
                    label: const Text('Upload CSV File'),
                  ),
                ),
                if (_selectedFileName != null) ...[
                  const SizedBox(height: AtlasSpacing.sm),
                  AtlasInfoBanner(
                    icon: Icons.description_outlined,
                    title: 'Selected File',
                    message: _selectedFileName!,
                  ),
                ],
                if (_operationError != null) ...[
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasInfoBanner(
                    icon: Icons.error_outline_rounded,
                    title: 'Import Problem',
                    message: _operationError!,
                    accentColor: AtlasColors.danger,
                  ),
                ],
                const SizedBox(height: AtlasSpacing.lg),
                TextField(
                  controller: _csvController,
                  minLines: 8,
                  maxLines: 14,
                  enabled: !_isImporting,
                  decoration: const InputDecoration(
                    hintText: 'Or paste CSV / tab-separated export here...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (_operationError == null && _importResult == null) {
                      return;
                    }

                    setState(() {
                      _operationError = null;
                      _importResult = null;
                    });
                  },
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
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _isImporting ? null : _clearCsv,
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          if (_parseResult != null) _CsvPreviewCard(result: _parseResult!),
          if (_importResult != null) ...[
            const SizedBox(height: AtlasSpacing.lg),
            _CsvImportResultCard(result: _importResult!),
          ],
        ],
      ),
    );
  }
}

class _CsvPreviewCard extends StatelessWidget {
  const _CsvPreviewCard({required this.result});

  final CsvImportParseResult result;

  @override
  Widget build(BuildContext context) {
    final bool hasIssues = result.errors.isNotEmpty;

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: 'Import Preview',
            subtitle: hasIssues
                ? 'Review the parsed data and any issues before importing.'
                : 'Your file was parsed successfully and is ready for review.',
            icon: Icons.visibility_outlined,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              AtlasStatusChip(
                label: '${result.parsedRows} Parsed',
                icon: Icons.inventory_2_outlined,
                accentColor: AtlasColors.vaultGold,
              ),
              AtlasStatusChip(
                label: '${result.skippedRows} Skipped',
                icon: Icons.skip_next_rounded,
                accentColor: AtlasColors.vaultGold,
              ),
              AtlasStatusChip(
                label: '${result.errors.length} Issues',
                icon: hasIssues
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline_rounded,
                accentColor: hasIssues
                    ? AtlasColors.warning
                    : AtlasColors.vaultGold,
              ),
            ],
          ),
          if (hasIssues) ...[
            const SizedBox(height: AtlasSpacing.lg),
            AtlasInfoBanner(
              icon: Icons.warning_amber_rounded,
              title: 'Issues Found',
              message: result.errors.take(5).join('\n'),
              accentColor: AtlasColors.warning,
            ),
          ],
        ],
      ),
    );
  }
}

class _CsvImportResultCard extends StatelessWidget {
  const _CsvImportResultCard({required this.result});

  final PopImportResult result;

  @override
  Widget build(BuildContext context) {
    final int totalCopies = result.added + result.skipped;

    return AtlasGlassCard(
      accentColor: AtlasColors.vaultGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AtlasSectionHeader(
            title: 'Import Complete',
            subtitle: 'Your collection import has finished.',
            icon: Icons.check_circle_outline_rounded,
            accentColor: AtlasColors.vaultGold,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              AtlasStatusChip(
                label: '${result.added} Added',
                icon: Icons.add_circle_outline_rounded,
                accentColor: AtlasColors.vaultGold,
              ),
              AtlasStatusChip(
                label: '${result.skipped} Consolidated',
                icon: Icons.merge_type_rounded,
                accentColor: AtlasColors.vaultGold,
              ),
              AtlasStatusChip(
                label: '$totalCopies Total Copies',
                icon: Icons.inventory_2_outlined,
                accentColor: AtlasColors.vaultGold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
