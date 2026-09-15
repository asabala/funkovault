import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_panel.dart';
import '../../atlas/atlas_stat_tile.dart';
import '../../atlas/components/atlas_info_banner.dart';
import '../../atlas/components/atlas_section_header.dart';

class VaultStatusSection extends StatelessWidget {
  const VaultStatusSection({
    super.key,
    required this.visibleCount,
    required this.totalCount,
    required this.searchedCount,
    required this.filterLabel,
    required this.sortLabel,
    required this.searchQuery,
    required this.resultCount,
    required this.currentValue,
    required this.missingValueCount,
    required this.duplicateGroupCount,
    required this.showDuplicateGroups,
    this.cleanupFocusTitle,
    this.cleanupFocusMessage,
    this.onClearCleanupFocus,
  });

  final int visibleCount;
  final int totalCount;
  final int searchedCount;

  final String filterLabel;
  final String sortLabel;
  final String searchQuery;

  final int resultCount;
  final double currentValue;
  final int missingValueCount;
  final int duplicateGroupCount;
  final bool showDuplicateGroups;

  final String? cleanupFocusTitle;
  final String? cleanupFocusMessage;
  final VoidCallback? onClearCleanupFocus;

  bool get _hasSearch {
    return searchQuery.trim().isNotEmpty;
  }

  bool get _hasCleanupFocus {
    return cleanupFocusTitle != null &&
        cleanupFocusTitle!.trim().isNotEmpty &&
        cleanupFocusMessage != null &&
        cleanupFocusMessage!.trim().isNotEmpty &&
        onClearCleanupFocus != null;
  }

  @override
  Widget build(BuildContext context) {
    final searchLabel = _hasSearch
        ? 'Search: "${searchQuery.trim()}"'
        : 'Search: None';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasCleanupFocus) ...[
          AtlasInfoBanner(
            icon: Icons.filter_alt_rounded,
            title: cleanupFocusTitle!,
            message: cleanupFocusMessage!,
            actionLabel: 'Clear Focus',
            onAction: onClearCleanupFocus,
          ),
          const SizedBox(height: AtlasSpacing.md),
        ],
        AtlasGlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Showing $visibleCount of $totalCount Pops',
                style: AtlasTypography.bodyMedium.copyWith(
                  color: AtlasColors.vaultGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AtlasSpacing.xs),
              Text(
                'Filter: $filterLabel • Sort: $sortLabel',
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                ),
              ),
              if (_hasSearch) ...[
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  '$searchLabel • Search matched $searchedCount',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AtlasSpacing.md),
        AtlasGlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AtlasSectionHeader(
                title: 'Current View',
                icon: Icons.visibility_rounded,
              ),
              const SizedBox(height: AtlasSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AtlasStatTile(
                      value: '$resultCount',
                      label: 'Results',
                    ),
                  ),
                  Expanded(
                    child: AtlasStatTile(
                      value: '\$${currentValue.toStringAsFixed(0)}',
                      label: 'Value',
                    ),
                  ),
                  Expanded(
                    child: AtlasStatTile(
                      value: showDuplicateGroups
                          ? '$duplicateGroupCount'
                          : '$missingValueCount',
                      label: showDuplicateGroups ? 'Groups' : 'Need Value',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
