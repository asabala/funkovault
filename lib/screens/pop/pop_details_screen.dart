import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/components/atlas_chip.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/pop/pop_source_details_section.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import 'edit_pop_screen.dart';

class PopDetailsScreen extends StatefulWidget {
  const PopDetailsScreen({super.key, required this.pop});

  final Pop pop;

  @override
  State<PopDetailsScreen> createState() => _PopDetailsScreenState();
}

class _PopDetailsScreenState extends State<PopDetailsScreen> {
  late Pop pop;

  @override
  void initState() {
    super.initState();
    pop = widget.pop;
  }

  Future<void> _editPop() async {
    final updatedPop = await Navigator.push<Pop>(
      context,
      MaterialPageRoute(builder: (_) => EditPopScreen(pop: pop)),
    );

    if (updatedPop != null) {
      setState(() {
        pop = updatedPop;
      });
    }
  }

  Future<void> _editValue() async {
    final updatedPop = await Navigator.push<Pop>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPopScreen(pop: pop, focusValueField: true),
      ),
    );

    if (updatedPop == null || !mounted) {
      return;
    }

    setState(() {
      pop = updatedPop;
    });
  }

  Future<void> _confirmDeletePop() async {
    final appState = context.read<AppState>();
    final navigator = Navigator.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Pop?'),
          content: Text(
            'This will remove "${pop.name}" from the current collection. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await appState.deletePop(pop.id);

    if (!mounted) {
      return;
    }

    navigator.pop();
  }

  Future<void> _toggleWishlist() async {
    final updatedPop = pop.copyWith(
      isWishlist: !pop.isWishlist,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    await context.read<AppState>().updatePop(updatedPop);

    setState(() {
      pop = updatedPop;
    });
  }

  Future<void> _updateQuantity(int newQuantity) async {
    if (newQuantity < 1) {
      return;
    }

    final updatedPop = pop.copyWith(
      quantity: newQuantity,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    await context.read<AppState>().updatePop(updatedPop);

    setState(() {
      pop = updatedPop;
    });
  }

  @override
  Widget build(BuildContext context) {
    final numberLabel = pop.number.trim().isEmpty
        ? 'No #'
        : '#${pop.number.trim()}';
    final valueLabel = pop.value <= 0
        ? 'Value needed'
        : '\$${pop.value.toStringAsFixed(2)}';
    final paidLabel = pop.pricePaid <= 0
        ? 'Not entered'
        : '\$${pop.pricePaid.toStringAsFixed(2)}';
    final dateAddedLabel = _formatDateLabel(pop.dateAdded);
    final lastUpdatedLabel = _formatDateLabel(pop.lastUpdated);

    return Scaffold(
      appBar: AppBar(
        title: Text(pop.name),
        actions: [
          IconButton(
            icon: Icon(
              pop.isWishlist ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleWishlist,
          ),
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: _editPop),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _confirmDeletePop,
          ),
        ],
      ),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _PopHeroImage(imageUrl: pop.imageUrl)),
                const SizedBox(height: AtlasSpacing.lg),
                Text(
                  pop.name,
                  style: AtlasTypography.headingLarge,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Wrap(
                  spacing: AtlasSpacing.sm,
                  runSpacing: AtlasSpacing.sm,
                  children: [
                    AtlasChip(label: numberLabel),
                    AtlasChip(label: pop.owner),
                    AtlasChip(
                      label: pop.isWishlist ? 'Wishlist' : 'Owned',
                      icon: pop.isWishlist
                          ? Icons.favorite_rounded
                          : Icons.inventory_2_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: AtlasSpacing.lg),
                AtlasGlassPanel(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _QuickStatLine(
                          label: 'Value',
                          value: valueLabel,
                        ),
                      ),
                      const SizedBox(width: AtlasSpacing.sm),
                      Expanded(
                        child: _QuickStatLine(
                          label: 'Quantity',
                          value: '${pop.quantity}',
                          alignment: CrossAxisAlignment.center,
                        ),
                      ),
                      const SizedBox(width: AtlasSpacing.sm),
                      Expanded(
                        child: _QuickStatLine(
                          label: 'Release',
                          value: pop.collectorLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AtlasSpacing.lg),
                AtlasGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AtlasSectionHeader(
                        title: 'Collection Information',
                        subtitle:
                            'Collectible details, ownership, value, and condition',
                        icon: Icons.inventory_2_outlined,
                      ),

                      const SizedBox(height: AtlasSpacing.lg),
                      Text('Timeline', style: AtlasTypography.headingSmall),
                      const SizedBox(height: AtlasSpacing.sm),
                      _DetailRow(label: 'Added', value: dateAddedLabel),
                      _DetailRow(label: 'Updated', value: lastUpdatedLabel),

                      const SizedBox(height: AtlasSpacing.lg),
                      Text(
                        'Basic Information',
                        style: AtlasTypography.headingSmall,
                      ),
                      const SizedBox(height: AtlasSpacing.sm),
                      _DetailRow(label: 'Number', value: pop.number),
                      _DetailRow(label: 'Category', value: pop.category),
                      _DetailRow(label: 'Series', value: pop.series),
                      _DetailRow(label: 'Edition', value: pop.edition),
                      _DetailRow(label: 'Owner', value: pop.owner),

                      const SizedBox(height: AtlasSpacing.lg),
                      Text(
                        'Collector Identity',
                        style: AtlasTypography.headingSmall,
                      ),
                      const SizedBox(height: AtlasSpacing.sm),
                      _IdentityBadgeWrap(pop: pop),
                      const SizedBox(height: AtlasSpacing.md),
                      _DetailRow(label: 'Variant', value: pop.variant),
                      _DetailRow(
                        label: 'Retail Exclusive',
                        value: pop.retailExclusive,
                      ),
                      _DetailRow(
                        label: 'Event Sticker',
                        value: pop.eventSticker,
                      ),
                      _DetailRow(
                        label: 'Limited Edition',
                        value: pop.limitedEdition,
                      ),
                      _DetailRow(label: 'Signature', value: pop.signature),

                      const SizedBox(height: AtlasSpacing.lg),
                      Text(
                        'Value & Condition',
                        style: AtlasTypography.headingSmall,
                      ),
                      const SizedBox(height: AtlasSpacing.sm),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AtlasGlassPanel(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Quantity',
                                    style: AtlasTypography.bodySmall.copyWith(
                                      color: AtlasColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AtlasSpacing.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        tooltip: 'Decrease quantity',
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        padding: EdgeInsets.zero,
                                        iconSize: 22,
                                        icon: const Icon(
                                          Icons.remove_circle_outline_rounded,
                                        ),
                                        onPressed: pop.quantity <= 1
                                            ? null
                                            : () => _updateQuantity(
                                                pop.quantity - 1,
                                              ),
                                      ),
                                      SizedBox(
                                        width: 24,
                                        child: Text(
                                          '${pop.quantity}',
                                          textAlign: TextAlign.center,
                                          style: AtlasTypography.headingSmall
                                              .copyWith(
                                                color: AtlasColors.vaultGold,
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Increase quantity',
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        padding: EdgeInsets.zero,
                                        iconSize: 22,
                                        icon: const Icon(
                                          Icons.add_circle_outline_rounded,
                                        ),
                                        onPressed: () =>
                                            _updateQuantity(pop.quantity + 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AtlasSpacing.sm),
                          Expanded(
                            child: AtlasGlassPanel(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Current Value',
                                    style: AtlasTypography.bodySmall.copyWith(
                                      color: AtlasColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AtlasSpacing.md),
                                  Text(
                                    valueLabel,
                                    textAlign: TextAlign.center,
                                    style: AtlasTypography.headingSmall
                                        .copyWith(color: AtlasColors.vaultGold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AtlasSpacing.sm),
                      _DetailRow(label: 'Price Paid', value: paidLabel),
                      _DetailRow(
                        label: 'Item Condition',
                        value: pop.itemCondition,
                      ),
                      _DetailRow(
                        label: 'Box Condition',
                        value: pop.boxCondition,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (pop.sourceCatalogId.trim().isNotEmpty ||
              pop.sourceCollectibleId.trim().isNotEmpty ||
              pop.sourceUpc.trim().isNotEmpty ||
              pop.productionStatus.trim().isNotEmpty ||
              pop.releaseDate.trim().isNotEmpty ||
              pop.gradingCompany.trim().isNotEmpty ||
              pop.authenticityNumber.trim().isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.lg),
            PopSourceDetailsSection(pop: pop),
          ],
          const SizedBox(height: AtlasSpacing.lg),
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AtlasSectionHeader(
                  title: 'Collection Actions',
                  subtitle: 'Manage ownership, value, and collectible details',
                  icon: Icons.tune_rounded,
                ),
                const SizedBox(height: AtlasSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _editValue,
                    icon: Icon(
                      pop.value <= 0
                          ? Icons.add_chart_rounded
                          : Icons.price_change_rounded,
                    ),
                    label: Text(
                      pop.value <= 0
                          ? 'Add Current Value'
                          : 'Update Current Value',
                    ),
                  ),
                ),
                const SizedBox(height: AtlasSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _editPop,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Pop Details'),
                  ),
                ),
                const SizedBox(height: AtlasSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _toggleWishlist,
                    icon: Icon(
                      pop.isWishlist
                          ? Icons.inventory_2_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    label: Text(
                      pop.isWishlist
                          ? 'Move to Owned Collection'
                          : 'Move to Wishlist',
                    ),
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                Divider(
                  color: AtlasColors.textSecondary.withValues(alpha: 0.18),
                ),
                const SizedBox(height: AtlasSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmDeletePop,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete Pop'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopHeroImage extends StatelessWidget {
  const _PopHeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final cleanImageUrl = imageUrl.trim();

    return Container(
      width: 170,
      height: 210,
      decoration: BoxDecoration(
        color: AtlasColors.textSecondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AtlasSpacing.lg),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanImageUrl.isEmpty
          ? const Icon(Icons.inventory_2_rounded, size: 72)
          : Image.network(
              cleanImageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image_rounded, size: 72);
              },
            ),
    );
  }
}

class _QuickStatLine extends StatelessWidget {
  const _QuickStatLine({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AtlasSpacing.xs),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _displayValue(value),
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
            textAlign: alignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.start,
            softWrap: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _displayValue(value),
              style: AtlasTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityBadgeWrap extends StatelessWidget {
  const _IdentityBadgeWrap({required this.pop});

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final badges = _buildBadges();

    if (badges.isEmpty) {
      return const AtlasChip(label: 'Common / Standard');
    }

    return Wrap(
      spacing: AtlasSpacing.sm,
      runSpacing: AtlasSpacing.sm,
      children: badges.map((badge) => AtlasChip(label: badge)).toList(),
    );
  }

  List<String> _buildBadges() {
    final badges = <String>[];

    if (_hasMeaningfulValue(pop.variant)) {
      badges.add(_cleanBadgeLabel(pop.variant));
    }

    if (_hasMeaningfulValue(pop.retailExclusive)) {
      badges.add('Exclusive');
    }

    if (_hasMeaningfulValue(pop.eventSticker)) {
      badges.add('Sticker');
    }

    if (_hasMeaningfulValue(pop.limitedEdition)) {
      badges.add('Limited');
    }

    if (_hasMeaningfulValue(pop.signature)) {
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

String _displayValue(String value) {
  final cleaned = value.trim();

  if (cleaned.isEmpty) {
    return 'Not entered';
  }

  if (cleaned.toLowerCase() == 'none') {
    return 'None';
  }

  return cleaned;
}
