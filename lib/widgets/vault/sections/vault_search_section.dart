import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_search_field.dart';
import '../../atlas/components/atlas_section_header.dart';

class VaultSearchSection extends StatelessWidget {
  const VaultSearchSection({
    super.key,
    required this.controller,
    required this.resultCount,
    required this.totalCount,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final int resultCount;
  final int totalCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasSearch = controller.text.trim().isNotEmpty;

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AtlasSectionHeader(
            title: 'Search Vault',
            icon: Icons.search_rounded,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasSearchField(
            controller: controller,
            hintText: 'Search by name, number, category, series, or owner...',
            onChanged: onChanged,
            onClear: onClear,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            hasSearch
                ? '$resultCount of $totalCount Pops match your search.'
                : '$totalCount Pops in your vault.',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
