import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../services/duplicate_review_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/vault_scroll_view.dart';

class PossibleDuplicatesScreen extends StatefulWidget {
  const PossibleDuplicatesScreen({super.key});

  @override
  State<PossibleDuplicatesScreen> createState() =>
      _PossibleDuplicatesScreenState();
}

class _PossibleDuplicatesScreenState extends State<PossibleDuplicatesScreen> {
  _DuplicateReviewFilter _filter = _DuplicateReviewFilter.all;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pops = appState.selectedCollectionPops;

    final duplicateReport = const DuplicateReviewService().buildReport(pops);
    final sameIdentityGroups = duplicateReport.sameIdentityGroups;
    final possibleVariantGroups = duplicateReport.possibleVariantGroups;

    final showSameIdentity = _filter == _DuplicateReviewFilter.all ||
        _filter == _DuplicateReviewFilter.sameIdentity;

    final showPossibleVariants = _filter == _DuplicateReviewFilter.all ||
        _filter == _DuplicateReviewFilter.possibleVariants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Possible Duplicates'),
      ),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duplicate Review',
                  style: AtlasTypography.headingLarge,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Atlas separates same identity groups from possible variants. Nothing is deleted or merged from this screen.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                AtlasGlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryLine(
                        label: 'Same Identity Groups',
                        value: '${sameIdentityGroups.length}',
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      _SummaryLine(
                        label: 'Possible Variant Groups',
                        value: '${possibleVariantGroups.length}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _DuplicateFilterCard(
            selectedFilter: _filter,
            onChanged: (filter) {
              setState(() {
                _filter = filter;
              });
            },
          ),
          if (showSameIdentity) ...[
            const SizedBox(height: AtlasSpacing.lg),
            _DuplicateSection(
              title: 'Same Identity Groups',
              subtitle:
              'These match on the stricter collectible identity key. Review these first because they may be the same Pop with different values or quantities.',
              emptyMessage: 'No same identity groups found.',
              groups: sameIdentityGroups,
              badgeText: 'Identity',
              badgeColor: AtlasColors.vaultGold,
            ),
          ],
          if (showPossibleVariants) ...[
            const SizedBox(height: AtlasSpacing.lg),
            _DuplicateSection(
              title: 'Possible Variant Groups',
              subtitle:
              'These share the same name and number, but may be legitimate variants such as chase, metallic, exclusive, sticker, limited edition, or signed Pops.',
              emptyMessage: 'No possible variant groups found.',
              groups: possibleVariantGroups,
              badgeText: 'Review',
              badgeColor: AtlasColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}

enum _DuplicateReviewFilter {
  all,
  sameIdentity,
  possibleVariants,
}

class _DuplicateFilterCard extends StatelessWidget {
  const _DuplicateFilterCard({
    required this.selectedFilter,
    required this.onChanged,
  });

  final _DuplicateReviewFilter selectedFilter;
  final ValueChanged<_DuplicateReviewFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Filter',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            'Choose which duplicate groups you want to review.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              _FilterChipButton(
                label: 'All',
                selected: selectedFilter == _DuplicateReviewFilter.all,
                onSelected: () => onChanged(_DuplicateReviewFilter.all),
              ),
              _FilterChipButton(
                label: 'Same Identity',
                selected: selectedFilter == _DuplicateReviewFilter.sameIdentity,
                onSelected: () =>
                    onChanged(_DuplicateReviewFilter.sameIdentity),
              ),
              _FilterChipButton(
                label: 'Possible Variants',
                selected:
                selectedFilter == _DuplicateReviewFilter.possibleVariants,
                onSelected: () =>
                    onChanged(_DuplicateReviewFilter.possibleVariants),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AtlasColors.vaultGold.withValues(alpha: 0.22),
      labelStyle: AtlasTypography.bodySmall.copyWith(
        color: selected ? AtlasColors.vaultGold : AtlasColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected
            ? AtlasColors.vaultGold.withValues(alpha: 0.70)
            : AtlasColors.textSecondary.withValues(alpha: 0.22),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          style: AtlasTypography.headingSmall.copyWith(
            color: AtlasColors.vaultGold,
          ),
        ),
      ],
    );
  }
}

class _DuplicateSection extends StatelessWidget {
  const _DuplicateSection({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.groups,
    required this.badgeText,
    required this.badgeColor,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<DuplicateReviewGroup> groups;
  final String badgeText;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            subtitle,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          if (groups.isEmpty)
            AtlasGlassPanel(
              child: Text(
                emptyMessage,
                style: AtlasTypography.bodyMedium.copyWith(
                  color: AtlasColors.textSecondary,
                ),
              ),
            )
          else
            ...groups.map(
                  (group) => Padding(
                padding: const EdgeInsets.only(bottom: AtlasSpacing.md),
                child: _DuplicateGroupCard(
                  group: group,
                  badgeText: badgeText,
                  badgeColor: badgeColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DuplicateGroupCard extends StatelessWidget {
  const _DuplicateGroupCard({
    required this.group,
    required this.badgeText,
    required this.badgeColor,
  });

  final DuplicateReviewGroup group;
  final String badgeText;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final firstPop = group.pops.first;
    final numberLabel = firstPop.number.trim().isEmpty
        ? 'No #'
        : '#${firstPop.number.trim()}';

    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DuplicateBadge(
                text: badgeText,
                color: badgeColor,
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(
                  firstPop.name,
                  style: AtlasTypography.headingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            '$numberLabel • ${group.pops.length} matching item${group.pops.length == 1 ? '' : 's'}',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          _GroupReviewRecommendation(
            pops: group.pops,
          ),
          const SizedBox(height: AtlasSpacing.md),
          _GroupDifferenceSummary(
            pops: group.pops,
          ),
          const SizedBox(height: AtlasSpacing.md),
          ...group.pops.map(
                (pop) => Padding(
              padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
              child: _DuplicatePopTile(
                pop: pop,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupReviewRecommendation extends StatelessWidget {
  const _GroupReviewRecommendation({
    required this.pops,
  });

  final List<Pop> pops;

  @override
  Widget build(BuildContext context) {
    final recommendation = _buildRecommendation();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AtlasSpacing.md),
        border: Border.all(
          color: recommendation.isHighRisk
              ? AtlasColors.textSecondary.withValues(alpha: 0.28)
              : AtlasColors.vaultGold.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Recommendation',
            style: AtlasTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: recommendation.isHighRisk
                  ? AtlasColors.textSecondary
                  : AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            recommendation.message,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  _ReviewRecommendation _buildRecommendation() {
    final variantValues = _uniqueValues(
      pops.map((pop) => pop.variant),
    );
    final exclusiveValues = _uniqueValues(
      pops.map((pop) => pop.retailExclusive),
    );
    final stickerValues = _uniqueValues(
      pops.map((pop) => pop.eventSticker),
    );
    final limitedValues = _uniqueValues(
      pops.map((pop) => pop.limitedEdition),
    );
    final signatureValues = _uniqueValues(
      pops.map((pop) => pop.signature),
    );
    final wishlistValues = _uniqueValues(
      pops.map((pop) => pop.isWishlist ? 'Wishlist' : 'Owned'),
    );

    final identityDiffers = variantValues.length > 1 ||
        exclusiveValues.length > 1 ||
        stickerValues.length > 1 ||
        limitedValues.length > 1 ||
        signatureValues.length > 1 ||
        wishlistValues.length > 1;

    if (identityDiffers) {
      return const _ReviewRecommendation(
        isHighRisk: true,
        message:
        'Possible variant. Variant, exclusive, sticker, limited edition, signature, or wishlist status differs. Do not auto-merge this group.',
      );
    }

    final seriesValues = _uniqueValues(
      pops.map((pop) => pop.series),
    );
    final ownerValues = _uniqueValues(
      pops.map((pop) => pop.owner),
    );
    final valueValues = _uniqueValues(
      pops.map((pop) => pop.value.toStringAsFixed(0)),
    );
    final quantityValues = _uniqueValues(
      pops.map((pop) => pop.quantity.toString()),
    );

    final onlyDataDiffers = seriesValues.length > 1 ||
        ownerValues.length > 1 ||
        valueValues.length > 1 ||
        quantityValues.length > 1;

    if (onlyDataDiffers) {
      return const _ReviewRecommendation(
        isHighRisk: false,
        message:
        'Likely same Pop identity. Differences appear to be value, quantity, owner, or series naming. Review before cleanup.',
      );
    }

    return const _ReviewRecommendation(
      isHighRisk: false,
      message:
      'Strong same-identity match. This group appears to have matching identity fields. Review before any cleanup action.',
    );
  }

  Set<String> _uniqueValues(Iterable<String> values) {
    return values
        .map(
          (value) => value.trim().isEmpty ? 'Blank' : value.trim().toLowerCase(),
    )
        .toSet();
  }
}

class _ReviewRecommendation {
  const _ReviewRecommendation({
    required this.isHighRisk,
    required this.message,
  });

  final bool isHighRisk;
  final String message;
}

class _GroupDifferenceSummary extends StatelessWidget {
  const _GroupDifferenceSummary({
    required this.pops,
  });

  final List<Pop> pops;

  @override
  Widget build(BuildContext context) {
    final differences = _buildDifferences();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AtlasSpacing.md),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Difference Summary',
            style: AtlasTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          ...differences.map(
                (difference) => Padding(
              padding: const EdgeInsets.only(bottom: AtlasSpacing.xs),
              child: Text(
                difference,
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildDifferences() {
    final differences = <String>[];

    _addDifference(
      differences,
      label: 'Values',
      values: pops.map((pop) => pop.value.toStringAsFixed(0)).toSet(),
      sameText: 'Values match.',
      differentText: 'Values differ.',
    );

    _addDifference(
      differences,
      label: 'Quantity',
      values: pops.map((pop) => pop.quantity.toString()).toSet(),
      sameText: 'Quantities match.',
      differentText: 'Quantities differ.',
    );

    _addDifference(
      differences,
      label: 'Owner',
      values: pops.map((pop) => pop.owner.trim()).toSet(),
      sameText: 'Owners match.',
      differentText: 'Owners differ.',
    );

    _addDifference(
      differences,
      label: 'Series',
      values: pops.map((pop) => pop.series.trim()).toSet(),
      sameText: 'Series matches.',
      differentText: 'Series differs.',
    );

    _addDifference(
      differences,
      label: 'Variant',
      values: pops.map((pop) => pop.variant.trim()).toSet(),
      sameText: 'Variants match.',
      differentText: 'Variants differ.',
    );

    _addDifference(
      differences,
      label: 'Exclusive',
      values: pops.map((pop) => pop.retailExclusive.trim()).toSet(),
      sameText: 'Retail exclusives match.',
      differentText: 'Retail exclusives differ.',
    );

    _addDifference(
      differences,
      label: 'Sticker',
      values: pops.map((pop) => pop.eventSticker.trim()).toSet(),
      sameText: 'Event stickers match.',
      differentText: 'Event stickers differ.',
    );

    _addDifference(
      differences,
      label: 'Limited',
      values: pops.map((pop) => pop.limitedEdition.trim()).toSet(),
      sameText: 'Limited edition fields match.',
      differentText: 'Limited edition fields differ.',
    );

    _addDifference(
      differences,
      label: 'Signature',
      values: pops.map((pop) => pop.signature.trim()).toSet(),
      sameText: 'Signatures match.',
      differentText: 'Signatures differ.',
    );

    _addDifference(
      differences,
      label: 'Wishlist',
      values: pops
          .map((pop) => pop.isWishlist ? 'Wishlist' : 'Owned')
          .toSet(),
      sameText: 'Wishlist/owned status matches.',
      differentText: 'Wishlist/owned status differs.',
    );

    return differences;
  }

  void _addDifference(
      List<String> differences, {
        required String label,
        required Set<String> values,
        required String sameText,
        required String differentText,
      }) {
    final cleanedValues = values
        .map((value) => value.trim().isEmpty ? 'Blank' : value.trim())
        .toSet();

    if (cleanedValues.length <= 1) {
      differences.add('✓ $sameText');
      return;
    }

    differences.add('⚠ $differentText $label: ${cleanedValues.join(' / ')}');
  }
}

class _DuplicateBadge extends StatelessWidget {
  const _DuplicateBadge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtlasSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.50),
        ),
      ),
      child: Text(
        text,
        style: AtlasTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DuplicatePopTile extends StatelessWidget {
  const _DuplicatePopTile({
    required this.pop,
  });

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final categoryLabel =
    pop.category.trim().isEmpty ? 'No category' : pop.category.trim();
    final seriesLabel =
    pop.series.trim().isEmpty ? 'No series' : pop.series.trim();
    final valueLabel =
    pop.value <= 0 ? 'Value needed' : '\$${pop.value.toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AtlasSpacing.md),
        border: Border.all(
          color: AtlasColors.textSecondary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pop.collectorLabel,
            style: AtlasTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            '$seriesLabel • $categoryLabel',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Exclusive: ${pop.retailExclusive} • Sticker: ${pop.eventSticker}',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Limited: ${pop.limitedEdition} • Signature: ${pop.signature}',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Owner: ${pop.owner} • Qty: ${pop.quantity} • $valueLabel • ${pop.isWishlist ? 'Wishlist' : 'Owned'}',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}