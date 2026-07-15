import 'package:flutter/material.dart';

import '../../models/pop.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
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

  @override
  Widget build(BuildContext context) {
    if (!_hasSourceDetails) {
      return const SizedBox.shrink();
    }

    return AtlasGlassCard(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(
            top: AtlasSpacing.md,
          ),
          leading: const Icon(
            Icons.storage_outlined,
          ),
          title: Text(
            'Source Catalog Details',
            style: AtlasTypography.headingSmall,
          ),
          subtitle: Text(
            'HobbyDB release and catalog information',
            style: AtlasTypography.bodySmall,
          ),
          initiallyExpanded: false,
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