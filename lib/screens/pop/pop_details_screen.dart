import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/collection/atlas_collection.dart';
import '../../atlas/engines/context/pop_context_explainer_engine.dart';
import '../../atlas/screens/atlas_timeline_screen.dart';
import '../../models/activity.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_expandable_section.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/pop/atlas_product_hero_card.dart';
import '../../widgets/pop/pop_ask_atlas_bottom_sheet.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import 'edit_pop_screen.dart';

class PopDetailsScreen extends StatefulWidget {
  const PopDetailsScreen({super.key, required this.pop, this.collectionName});

  final Pop pop;
  final String? collectionName;

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
      MaterialPageRoute(
        builder: (_) =>
            EditPopScreen(pop: pop, collectionName: widget.collectionName),
      ),
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
        builder: (_) => EditPopScreen(
          pop: pop,
          collectionName: widget.collectionName,
          focusValueField: true,
        ),
      ),
    );

    if (updatedPop == null || !mounted) {
      return;
    }

    setState(() {
      pop = updatedPop;
    });
  }

  void _openTimeline() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AtlasTimelineScreen()),
    );
  }

  void _openAskAtlas() {
    const explainerEngine = PopContextExplainerEngine();

    PopAskAtlasBottomSheet.show(
      context: context,
      pop: pop,
      activities: context.read<AppState>().activities,
      explainerEngine: explainerEngine,
    );
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

    final deleted = await appState.deletePop(
      pop.id,
      collectionName: widget.collectionName,
      recordKey: pop.collectionRecordKey,
    );

    if (!mounted) {
      return;
    }

    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This Pop could not be found. Nothing was deleted.'),
        ),
      );

      return;
    }

    navigator.pop();
  }

  Future<void> _toggleWishlist() async {
    final appState = context.read<AppState>();
    final movedToWishlist = !pop.isWishlist;

    final updatedPop = pop.copyWith(
      isWishlist: movedToWishlist,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    final persistedPop = await appState.updatePop(
      updatedPop,
      collectionName: widget.collectionName,
      existingRecordKey: pop.collectionRecordKey,
    );

    if (persistedPop == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This Pop could not be found. No changes were saved.',
            ),
          ),
        );
      }

      return;
    }

    await appState.addActivity(
      Activity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        popId: persistedPop.id,
        action: movedToWishlist ? 'wishlist_added' : 'wishlist_removed',
        popName: persistedPop.name,
        popNumber: persistedPop.number,
        owner: persistedPop.owner,
        actor: persistedPop.owner,
        details: movedToWishlist
            ? '${persistedPop.name} moved to the wishlist'
            : '${persistedPop.name} moved to the owned collection',
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      pop = persistedPop;
    });
  }

  Future<void> _updateQuantity(int newQuantity) async {
    if (newQuantity < 1 || newQuantity == pop.quantity) {
      return;
    }

    final appState = context.read<AppState>();
    final previousQuantity = pop.quantity;

    final updatedPop = pop.copyWith(
      quantity: newQuantity,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    final persistedPop = await appState.updatePop(
      updatedPop,
      collectionName: widget.collectionName,
      existingRecordKey: pop.collectionRecordKey,
    );

    if (persistedPop == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This Pop could not be found. No changes were saved.',
            ),
          ),
        );
      }

      return;
    }

    await appState.addActivity(
      Activity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        popId: persistedPop.id,
        action: 'quantity_updated',
        popName: persistedPop.name,
        popNumber: persistedPop.number,
        owner: persistedPop.owner,
        actor: persistedPop.owner,
        details:
            '${persistedPop.name} quantity changed from $previousQuantity to ${persistedPop.quantity}',
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      pop = persistedPop;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const collectionEngine = AtlasCollectionEngine();
    final intelligence = collectionEngine.analyze(
      pop: pop,
      activities: appState.activities,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(pop.name),
        actions: [
          IconButton(
            tooltip: pop.isWishlist ? 'Move to owned' : 'Move to wishlist',
            icon: Icon(
              pop.isWishlist ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleWishlist,
          ),
          IconButton(
            tooltip: 'Edit Pop',
            icon: const Icon(Icons.edit_rounded),
            onPressed: _editPop,
          ),
          PopupMenuButton<_PopMenuAction>(
            tooltip: 'More actions',
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _PopMenuAction.askAtlas,
                child: _MenuItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Ask Atlas',
                ),
              ),
              PopupMenuItem(
                value: _PopMenuAction.updateValue,
                child: _MenuItem(
                  icon: Icons.price_change_rounded,
                  label: pop.value <= 0 ? 'Add Current Value' : 'Update Value',
                ),
              ),
              const PopupMenuItem(
                value: _PopMenuAction.timeline,
                child: _MenuItem(
                  icon: Icons.timeline_rounded,
                  label: 'View Timeline',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _PopMenuAction.delete,
                child: _MenuItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete Pop',
                  destructive: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: VaultScrollView(
        children: [
          AtlasProductHeroCard(
            pop: pop,
            heroSummary: intelligence.heroSummary,
            trendPercent: null,
            trendTimeframe: '30d',
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasExpandableSection(
            title: 'Collection Details',
            subtitle: _collectionDetailsSubtitle(pop),
            icon: Icons.inventory_2_outlined,
            initiallyExpanded: false,
            badge: AtlasExpandableBadge(
              label: '${pop.quantity} owned',
              icon: Icons.inventory_2_rounded,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuantityControl(
                  quantity: pop.quantity,
                  onDecrease: pop.quantity <= 1
                      ? null
                      : () => _updateQuantity(pop.quantity - 1),
                  onIncrease: () => _updateQuantity(pop.quantity + 1),
                ),
                const SizedBox(height: AtlasSpacing.sm),
                _DetailRow(label: 'Owner', value: pop.owner),
                _DetailRow(
                  label: 'Purchase Price',
                  value: pop.pricePaid <= 0
                      ? 'Not entered'
                      : '\$${pop.pricePaid.toStringAsFixed(2)}',
                ),
                _DetailRow(label: 'Item Condition', value: pop.itemCondition),
                _DetailRow(label: 'Box Condition', value: pop.boxCondition),
                _DetailRow(label: 'Date Added', value: pop.dateAdded),
                if (_hasMeaningfulDetailValue(pop.releaseDate))
                  _DetailRow(label: 'Release', value: pop.releaseDate),
                if (_hasMeaningfulDetailValue(pop.productionStatus))
                  _DetailRow(
                    label: 'Production Status',
                    value: pop.productionStatus,
                  ),
                if (_hasMeaningfulDetailValue(pop.packagingType))
                  _DetailRow(label: 'Packaging', value: pop.packagingType),
                if (_hasMeaningfulDetailValue(pop.sourceCatalogId))
                  _DetailRow(label: 'Catalog ID', value: pop.sourceCatalogId),
                if (_hasMeaningfulDetailValue(pop.sourceCollectibleId))
                  _DetailRow(
                    label: 'Collectible ID',
                    value: pop.sourceCollectibleId,
                  ),
                if (_hasMeaningfulDetailValue(pop.sourceUpc))
                  _DetailRow(label: 'UPC', value: pop.sourceUpc),
                const SizedBox(height: AtlasSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openTimeline,
                    icon: const Icon(Icons.timeline_rounded),
                    label: Text(
                      pop.timeline.isEmpty
                          ? 'View Timeline'
                          : 'View Timeline (${pop.timeline.length})',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(_PopMenuAction action) async {
    switch (action) {
      case _PopMenuAction.askAtlas:
        _openAskAtlas();
        return;
      case _PopMenuAction.updateValue:
        await _editValue();
        return;
      case _PopMenuAction.timeline:
        _openTimeline();
        return;
      case _PopMenuAction.delete:
        await _confirmDeletePop();
        return;
    }
  }
}

enum _PopMenuAction { askAtlas, updateValue, timeline, delete }

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AtlasColors.danger : null;

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: AtlasSpacing.sm),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owned Quantity',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$quantity',
                  style: AtlasTypography.headingSmall.copyWith(
                    color: AtlasColors.vaultGold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Decrease quantity',
            onPressed: onDecrease,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          IconButton(
            tooltip: 'Increase quantity',
            onPressed: onIncrease,
            icon: const Icon(Icons.add_circle_outline_rounded),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
      child: AtlasGlassPanel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 112,
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
      ),
    );
  }
}

String _collectionDetailsSubtitle(Pop pop) {
  final parts = <String>[];

  if (pop.pricePaid > 0) {
    parts.add('purchase recorded');
  }
  if (_hasMeaningfulDetailValue(pop.itemCondition) ||
      _hasMeaningfulDetailValue(pop.boxCondition)) {
    parts.add('condition recorded');
  }
  if (pop.timeline.isNotEmpty) {
    parts.add(
      '${pop.timeline.length} timeline ${pop.timeline.length == 1 ? 'event' : 'events'}',
    );
  }

  if (parts.isEmpty) {
    return 'Ownership, purchase, condition, and history';
  }

  return parts.join(' • ');
}

bool _hasMeaningfulDetailValue(String value) {
  final cleaned = value.trim().toLowerCase();

  return cleaned.isNotEmpty &&
      cleaned != 'none' &&
      cleaned != 'no' &&
      cleaned != 'n/a' &&
      cleaned != 'na' &&
      cleaned != 'unknown' &&
      cleaned != 'not entered';
}

String _displayValue(String value) {
  final cleaned = value.trim();
  return cleaned.isEmpty ? 'Not entered' : cleaned;
}
