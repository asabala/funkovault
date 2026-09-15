import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_action_row.dart';
import '../../atlas/components/atlas_chip.dart';
import '../../atlas/components/atlas_info_banner.dart';
import '../../atlas/components/atlas_section_header.dart';

class VaultControlsSection<TFilter, TSort> extends StatelessWidget {
  const VaultControlsSection({
    super.key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.filterValues,
    required this.sortValues,
    required this.filterLabelBuilder,
    required this.sortLabelBuilder,
    required this.hasActiveControls,
    required this.showImages,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onImageVisibilityChanged,
    required this.onReset,
    required this.isDefaultFilter,
  });

  final TFilter selectedFilter;
  final TSort selectedSort;

  final List<TFilter> filterValues;
  final List<TSort> sortValues;

  final String Function(TFilter value) filterLabelBuilder;

  final String Function(TSort value) sortLabelBuilder;

  final bool hasActiveControls;
  final bool showImages;

  final ValueChanged<TFilter> onFilterChanged;

  final ValueChanged<TSort> onSortChanged;

  final ValueChanged<bool> onImageVisibilityChanged;

  final VoidCallback onReset;

  final bool Function(TFilter value) isDefaultFilter;

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilter = !isDefaultFilter(selectedFilter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtlasGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AtlasSectionHeader(
                title: 'Review Controls',
                subtitle:
                    'Filter and sort your vault. Filter, sort, and image settings are remembered.',
                icon: Icons.tune_rounded,
              ),

              if (hasActiveFilter) ...[
                const SizedBox(height: AtlasSpacing.md),
                AtlasChip(
                  label:
                      'Active Filter: '
                      '${filterLabelBuilder(selectedFilter)}',
                  icon: Icons.filter_alt_rounded,
                ),
              ],

              const SizedBox(height: AtlasSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _VaultDropdown<TFilter>(
                      label: 'Filter Vault',
                      icon: Icons.filter_list_rounded,
                      value: selectedFilter,
                      values: filterValues,
                      labelBuilder: filterLabelBuilder,
                      onChanged: onFilterChanged,
                    ),
                  ),

                  const SizedBox(width: AtlasSpacing.sm),

                  Container(
                    width: 1,
                    height: 48,
                    color: AtlasColors.textSecondary.withValues(alpha: 0.20),
                  ),

                  const SizedBox(width: AtlasSpacing.sm),

                  Expanded(
                    child: _VaultDropdown<TSort>(
                      label: 'Sort Vault',
                      icon: Icons.sort_rounded,
                      value: selectedSort,
                      values: sortValues,
                      labelBuilder: sortLabelBuilder,
                      onChanged: onSortChanged,
                    ),
                  ),
                ],
              ),

              if (hasActiveControls) ...[
                const SizedBox(height: AtlasSpacing.md),
                AtlasInfoBanner(
                  icon: Icons.bookmark_added_outlined,
                  title: 'Custom View Active',
                  message:
                      'Filter, sort, and image settings will be remembered.',
                  actionLabel: 'Reset View',
                  onAction: onReset,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AtlasSpacing.md),

        AtlasActionRow(
          title: showImages ? 'Hide Images' : 'Show Images',
          description: showImages
              ? 'Images are on. Turn them off for faster Vault scrolling.'
              : 'Images are off for faster scrolling. Turn them on to preview collectibles.',
          icon: showImages
              ? Icons.image_rounded
              : Icons.image_not_supported_outlined,
          accentColor: AtlasColors.vaultGold,
          onTap: () {
            onImageVisibilityChanged(!showImages);
          },
        ),
      ],
    );
  }
}

class _VaultDropdown<T> extends StatelessWidget {
  const _VaultDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final T value;
  final List<T> values;

  final String Function(T value) labelBuilder;

  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AtlasSpacing.sm,
          vertical: AtlasSpacing.sm,
        ),
      ),
      items: values
          .map(
            (T item) => DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item), overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (T? newValue) {
        if (newValue == null) {
          return;
        }

        onChanged(newValue);
      },
    );
  }
}
