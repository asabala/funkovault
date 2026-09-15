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
import '../pop/pop_details_screen.dart';
import '../../theme/atlas_motion.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_chip.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_product_image.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';

class PossibleDuplicatesScreen extends StatefulWidget {
  const PossibleDuplicatesScreen({super.key, required this.collectionName});

  final String collectionName;

  @override
  State<PossibleDuplicatesScreen> createState() =>
      _PossibleDuplicatesScreenState();
}

class _PossibleDuplicatesScreenState extends State<PossibleDuplicatesScreen> {
  final ScrollController _scrollController = ScrollController();

  _DuplicateReviewFilter _filter = _DuplicateReviewFilter.all;
  bool _showBackToTop = false;
  bool _showImages = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScrollPosition() {
    final shouldShow = _scrollController.offset > 500;

    if (shouldShow != _showBackToTop) {
      setState(() {
        _showBackToTop = shouldShow;
      });
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,
      duration: AtlasMotion.emphasis,
      curve: AtlasMotion.enter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pops = appState.popsForCollection(widget.collectionName);

    final duplicateReport = const DuplicateReviewService().buildReport(pops);
    final sameIdentityGroups = duplicateReport.sameIdentityGroups;
    final possibleVariantGroups = duplicateReport.possibleVariantGroups;

    final showSameIdentity =
        _filter == _DuplicateReviewFilter.all ||
        _filter == _DuplicateReviewFilter.sameIdentity;

    final showPossibleVariants =
        _filter == _DuplicateReviewFilter.all ||
        _filter == _DuplicateReviewFilter.possibleVariants;

    return Scaffold(
      appBar: AppBar(title: const Text('Atlas Identity Intelligence')),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.extended(
              onPressed: _scrollToTop,
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
              label: const Text('Top'),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AtlasSpacing.md,
            AtlasSpacing.md,
            AtlasSpacing.md,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AtlasGlassCard(
                accentColor: AtlasColors.vaultGold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AtlasSectionHeader(
                      title: 'Atlas Identity Intelligence',
                      subtitle:
                          'Atlas separates exact duplicates from related collectible releases and explains meaningful differences such as variants, stickers, finishes, packaging, production runs, signatures, and authentication.',
                      icon: Icons.manage_search_rounded,
                      accentColor: AtlasColors.vaultGold,
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    Wrap(
                      spacing: AtlasSpacing.sm,
                      runSpacing: AtlasSpacing.sm,
                      children: [
                        AtlasStatusChip(
                          label:
                              '${duplicateReport.exactDuplicateGroupCount} Exact Duplicates',
                          icon: Icons.content_copy_rounded,
                          accentColor: AtlasColors.vaultGold,
                        ),
                        AtlasStatusChip(
                          label:
                              '${duplicateReport.reviewGroupCount} Review Groups',
                          icon: Icons.compare_arrows_rounded,
                          accentColor: AtlasColors.vaultGold,
                        ),
                        AtlasStatusChip(
                          label: '${duplicateReport.totalGroups} Total Groups',
                          icon: Icons.inventory_2_outlined,
                          accentColor: AtlasColors.vaultGold,
                        ),
                      ],
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
              const SizedBox(height: AtlasSpacing.md),

              AtlasActionRow(
                title: _showImages
                    ? 'Hide Review Images'
                    : 'Show Review Images',
                description: _showImages
                    ? 'Images are on. Turn them off for faster scrolling.'
                    : 'Images are off for faster scrolling. Turn them on when visual comparison is useful.',
                icon: _showImages
                    ? Icons.image_rounded
                    : Icons.image_not_supported_outlined,
                accentColor: AtlasColors.vaultGold,
                onTap: () {
                  setState(() {
                    _showImages = !_showImages;
                  });
                },
              ),
              if (showSameIdentity) ...[
                const SizedBox(height: AtlasSpacing.lg),
                _DuplicateSection(
                  collectionName: widget.collectionName,
                  title: 'Exact Duplicate Groups',
                  subtitle:
                      'These records share the same Atlas release fingerprint. Review them before consolidating quantities or correcting collection data.',
                  emptyMessage: 'No exact duplicate groups found.',
                  groups: sameIdentityGroups,
                  badgeText: 'Exact',
                  badgeColor: AtlasColors.vaultGold,
                  showImages: _showImages,
                ),
              ],
              if (showPossibleVariants) ...[
                const SizedBox(height: AtlasSpacing.lg),
                _DuplicateSection(
                  collectionName: widget.collectionName,
                  title: 'Related Release Groups',
                  subtitle:
                      'These collectibles share a broad identity but contain meaningful differences. Atlas classifies the strongest known difference and explains why the group needs review.',
                  emptyMessage: 'No related release groups found.',
                  groups: possibleVariantGroups,
                  badgeText: 'Review',
                  badgeColor: AtlasColors.textSecondary,
                  showImages: _showImages,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _DuplicateReviewFilter { all, sameIdentity, possibleVariants }

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
          const AtlasSectionHeader(
            title: 'Review Filter',
            subtitle: 'Choose which identity groups you want to review.',
            icon: Icons.filter_alt_outlined,
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
                label: 'Exact Duplicates',
                selected: selectedFilter == _DuplicateReviewFilter.sameIdentity,
                onSelected: () =>
                    onChanged(_DuplicateReviewFilter.sameIdentity),
              ),
              _FilterChipButton(
                label: 'Related Releases',
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

class _DuplicateSection extends StatelessWidget {
  const _DuplicateSection({
    required this.collectionName,
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.groups,
    required this.badgeText,
    required this.badgeColor,
    required this.showImages,
  });

  final String collectionName;
  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<DuplicateReviewGroup> groups;
  final String badgeText;
  final Color badgeColor;
  final bool showImages;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: Icons.content_copy_rounded,
          ),
          const SizedBox(height: AtlasSpacing.md),
          if (groups.isEmpty)
            AtlasEmptyState(
              eyebrow: 'Identity Review',
              title: 'No Groups Found',
              message: emptyMessage,
              icon: Icons.task_alt_rounded,
              compact: true,
            )
          else
            ...groups.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: AtlasSpacing.md),
                child: _DuplicateGroupCard(
                  collectionName: collectionName,
                  group: group,
                  badgeText: badgeText,
                  badgeColor: badgeColor,
                  showImages: showImages,
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
    required this.collectionName,
    required this.group,
    required this.badgeText,
    required this.badgeColor,
    required this.showImages,
  });

  final String collectionName;
  final DuplicateReviewGroup group;
  final String badgeText;
  final Color badgeColor;
  final bool showImages;

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
              AtlasStatusChip(
                label: group.title.isEmpty ? badgeText : group.title,
                accentColor: badgeColor,
                size: AtlasStatusChipSize.compact,
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text(firstPop.name, style: AtlasTypography.headingSmall),
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
          _IdentityEvidenceCard(group: group),
          const SizedBox(height: AtlasSpacing.md),
          _GroupDifferenceSummary(pops: group.pops),
          const SizedBox(height: AtlasSpacing.md),
          ...group.pops.map(
            (pop) => Padding(
              padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
              child: _DuplicatePopTile(
                pop: pop,
                showImages: showImages,
                collectionName: collectionName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityEvidenceCard extends StatelessWidget {
  const _IdentityEvidenceCard({required this.group});

  final DuplicateReviewGroup group;

  @override
  Widget build(BuildContext context) {
    final evidence = group.evidence.isEmpty
        ? const <String>[
            'Atlas found a related collectible identity that requires review.',
          ]
        : group.evidence;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AtlasSpacing.md),
        border: Border.all(
          color: group.isExactDuplicate
              ? AtlasColors.vaultGold.withValues(alpha: 0.32)
              : AtlasColors.textSecondary.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.isExactDuplicate
                ? 'Atlas Match Evidence'
                : 'Atlas Review Evidence',
            style: AtlasTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: group.isExactDuplicate
                  ? AtlasColors.vaultGold
                  : AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            group.explanation,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            'Confidence: ${group.confidence}%',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          ...evidence.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AtlasSpacing.xs),
              child: Text(
                '• $item',
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
}

class _GroupDifferenceSummary extends StatelessWidget {
  const _GroupDifferenceSummary({required this.pops});

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
      values: pops.map((pop) => pop.isWishlist ? 'Wishlist' : 'Owned').toSet(),
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

class _DuplicatePopTile extends StatelessWidget {
  const _DuplicatePopTile({
    required this.pop,
    required this.showImages,
    required this.collectionName,
  });

  final Pop pop;
  final bool showImages;
  final String collectionName;

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PopDetailsScreen(pop: pop, collectionName: collectionName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryLabel = pop.category.trim().isEmpty
        ? 'No category'
        : pop.category.trim();
    final seriesLabel = pop.series.trim().isEmpty
        ? 'No series'
        : pop.series.trim();
    final valueLabel = pop.value <= 0
        ? 'Value needed'
        : '\$${pop.value.toStringAsFixed(0)}';
    final dateAddedLabel = _formatDateLabel(pop.dateAdded);
    final lastUpdatedLabel = _formatDateLabel(pop.lastUpdated);

    return Container(
      width: double.infinity,
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
          Center(
            child: showImages
                ? AtlasProductImage(
                    imageUrl: pop.imageUrl,
                    width: 120,
                    height: 150,
                    borderRadius: AtlasSpacing.md,
                    showBorder: true,
                  )
                : Container(
                    width: 120,
                    height: 150,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AtlasColors.textSecondary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AtlasSpacing.md),
                      border: Border.all(
                        color: AtlasColors.textSecondary.withValues(
                          alpha: 0.18,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: AtlasColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            pop.collectorLabel,
            style: AtlasTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          _DuplicateIdentityBadges(pop: pop),
          const SizedBox(height: AtlasSpacing.sm),
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
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Added: $dateAddedLabel',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Updated: $lastUpdatedLabel',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openDetails(context),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open Details'),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateLabel(String value) {
  final cleaned = value.trim();

  if (cleaned.isEmpty) {
    return 'Before date tracking';
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

class _DuplicateIdentityBadges extends StatelessWidget {
  const _DuplicateIdentityBadges({required this.pop});

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final badges = _buildBadges();

    if (badges.isEmpty) {
      return const AtlasChip(
        label: 'Common / Standard',
        size: AtlasChipSize.compact,
      );
    }

    return Wrap(
      spacing: AtlasSpacing.xs,
      runSpacing: AtlasSpacing.xs,
      children: badges
          .map((badge) => AtlasChip(label: badge, size: AtlasChipSize.compact))
          .toList(),
    );
  }

  List<String> _buildBadges() {
    final badges = <String>[];

    final variant = pop.variant.trim();
    final retailExclusive = pop.retailExclusive.trim();
    final eventSticker = pop.eventSticker.trim();
    final limitedEdition = pop.limitedEdition.trim();
    final signature = pop.signature.trim();

    if (_hasMeaningfulValue(variant)) {
      badges.add(_cleanBadgeLabel(variant));
    }

    if (_hasMeaningfulValue(retailExclusive)) {
      badges.add('Exclusive');
    }

    if (_hasMeaningfulValue(eventSticker)) {
      badges.add('Sticker');
    }

    if (_hasMeaningfulValue(limitedEdition)) {
      badges.add('Limited');
    }

    if (_hasMeaningfulValue(signature)) {
      badges.add('Signed');
    }

    if (pop.isWishlist) {
      badges.add('Wishlist');
    }

    return badges;
  }

  bool _hasMeaningfulValue(String value) {
    final cleaned = value.trim().toLowerCase();

    if (cleaned.isEmpty) {
      return false;
    }

    return cleaned != 'none' &&
        cleaned != 'common' &&
        cleaned != 'standard' &&
        cleaned != 'unsigned' &&
        cleaned != 'no' &&
        cleaned != 'n/a' &&
        cleaned != 'na';
  }

  String _cleanBadgeLabel(String value) {
    final cleaned = value.trim();

    if (cleaned.length <= 18) {
      return cleaned;
    }

    return '${cleaned.substring(0, 18)}...';
  }
}
