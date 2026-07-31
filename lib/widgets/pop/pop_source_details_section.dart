import 'package:flutter/material.dart';

import '../../models/pop.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_expandable_section.dart';
import '../atlas/atlas_glass_panel.dart';

class PopSourceDetailsSection extends StatelessWidget {
  const PopSourceDetailsSection({
    super.key,
    required this.pop,
  });

  final Pop pop;

  bool get _hasSourceDetails {
    return pop.sourceCatalogId.trim().isNotEmpty ||
        pop.sourceCollectibleId.trim().isNotEmpty ||
        pop.sourceUpc.trim().isNotEmpty ||
        pop.productionStatus.trim().isNotEmpty ||
        pop.releaseDate.trim().isNotEmpty ||
        pop.gradingCompany.trim().isNotEmpty ||
        pop.authenticityNumber.trim().isNotEmpty;
  }

  int get _detailCount {
    var count = 1; // Source

    if (pop.sourceCatalogId.trim().isNotEmpty) count++;
    if (pop.sourceCollectibleId.trim().isNotEmpty) count++;
    if (pop.sourceUpc.trim().isNotEmpty) count++;
    if (pop.productionStatus.trim().isNotEmpty) count++;
    if (pop.releaseDate.trim().isNotEmpty) count++;
    if (pop.gradingCompany.trim().isNotEmpty) count++;
    if (pop.authenticityNumber.trim().isNotEmpty) count++;

    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSourceDetails) {
      return const SizedBox.shrink();
    }

    return AtlasExpandableSection(
      title: 'Source Catalog',
      subtitle: 'HobbyDB release and catalog information',
      icon: Icons.storage_outlined,
      initiallyExpanded: false,
      badge: AtlasExpandableBadge(
        label: '$_detailCount Fields',
        icon: Icons.dataset_outlined,
      ),
      child: Column(
        children: [
          const _SourceDetailRow(
            label: 'Source',
            value: 'HobbyDB',
          ),
          if (pop.sourceCatalogId.trim().isNotEmpty)
            _SourceDetailRow(
              label: 'HDBID',
              value: pop.sourceCatalogId,
            ),
          if (pop.sourceCollectibleId.trim().isNotEmpty)
            _SourceDetailRow(
              label: 'HDBC Number',
              value: pop.sourceCollectibleId,
            ),
          if (pop.sourceUpc.trim().isNotEmpty)
            _SourceDetailRow(
              label: 'UPC',
              value: pop.sourceUpc,
            ),
          if (pop.productionStatus.trim().isNotEmpty)
            _SourceDetailRow(
              label: 'Production Status',
              value: pop.productionStatus,
            ),
          if (pop.releaseDate.trim().isNotEmpty)
            _SourceDetailRow(
              label: 'Release Date',
              value: _formatSourceDate(
                pop.releaseDate,
              ),
            ),
          if (pop.gradingCompany.trim().isNotEmpty)
            _SourceDetailRow(
              label: 'Grading Company',
              value: pop.gradingCompany,
            ),
          if (pop.authenticityNumber.trim().isNotEmpty)
            _SourceDetailRow(
              label: 'Authenticity Number',
              value: pop.authenticityNumber,
            ),
        ],
      ),
    );
  }
}

class _SourceDetailRow extends StatelessWidget {
  const _SourceDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AtlasSpacing.sm,
      ),
      child: AtlasGlassPanel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 132,
              child: Text(
                label,
                style: AtlasTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SelectableText(
                value.trim(),
                style: AtlasTypography.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatSourceDate(String value) {
  final cleaned = value.trim();

  if (cleaned.isEmpty) {
    return 'Not entered';
  }

  final parsed = DateTime.tryParse(cleaned);

  if (parsed == null) {
    return cleaned;
  }

  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  final year = parsed.year.toString();

  return '$month/$day/$year';
}