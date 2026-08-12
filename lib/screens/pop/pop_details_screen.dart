import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/engines/collection/pop_activity_summary_engine.dart';
import '../../atlas/engines/context/pop_context_explainer_engine.dart';
import '../../atlas/screens/atlas_timeline_screen.dart';
import '../../atlas/identity/pop/pop_identity_rule.dart';
import '../../widgets/pop/pop_ask_atlas_bottom_sheet.dart';
import 'edit_pop_screen.dart';
import '../../models/activity.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_expandable_section.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/completion/atlas_completion_loader.dart';
import '../../widgets/atlas/components/atlas_chip.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_insight_panel.dart';
import '../../widgets/atlas/components/atlas_metric_panel.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/pop/pop_source_details_section.dart';
import '../../widgets/timeline/atlas_timeline_card.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import '../../widgets/timeline/atlas_timeline_intelligence_card.dart';
import '../../widgets/pop/atlas_product_hero_card.dart';
import '../../widgets/collectibility/atlas_collectibility_card.dart';
import '../../widgets/recommendations/atlas_recommendations_card.dart';
import '../../atlas/collection/atlas_collection.dart';


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
  void _openTimeline() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AtlasTimelineScreen(),
      ),
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

    await appState.deletePop(pop.id);

    if (!mounted) {
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

    await appState.updatePop(updatedPop);

    await appState.addActivity(
      Activity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        popId: updatedPop.id,
        action: movedToWishlist ? 'wishlist_added' : 'wishlist_removed',
        popName: updatedPop.name,
        popNumber: updatedPop.number,
        owner: updatedPop.owner,
        actor: updatedPop.owner,
        details: movedToWishlist
            ? '${updatedPop.name} moved to the wishlist'
            : '${updatedPop.name} moved to the owned collection',
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      pop = updatedPop;
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

    await appState.updatePop(updatedPop);

    await appState.addActivity(
      Activity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        popId: updatedPop.id,
        action: 'quantity_updated',
        popName: updatedPop.name,
        popNumber: updatedPop.number,
        owner: updatedPop.owner,
        actor: updatedPop.owner,
        details:
        '${updatedPop.name} quantity changed from $previousQuantity to $newQuantity',
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      pop = updatedPop;
    });
  }

  @override
  Widget build(BuildContext context) {

    final valueLabel = pop.value <= 0
        ? 'Value needed'
        : '\$${pop.value.toStringAsFixed(2)}';
    final paidLabel = pop.pricePaid <= 0
        ? 'Not entered'
        : '\$${pop.pricePaid.toStringAsFixed(2)}';
    final appState = context.watch<AppState>();

    final popActivities = appState.recentActivities
        .where((activity) => _activityMatchesPop(activity, pop))
        .take(3)
        .toList();

    const collectionEngine = AtlasCollectionEngine();

    final intelligence = collectionEngine.analyze(
      pop: pop,
      activities: appState.activities,
    );

    final activitySummary = intelligence.activitySummary;
    final timelineReport = intelligence.timelineReport;

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
          AtlasProductHeroCard(
            pop: pop,
            heroSummary: intelligence.heroSummary,
            trendPercent: null,
            trendTimeframe: '30d',
            onCompleteListing: _editPop,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasCompletionLoader(
            pop: pop,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasCollectibilityCard(
            summary: intelligence.collectibilitySummary,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasRecommendationsCard(
            summary: intelligence.recommendationSummary,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasExpandableSection(
            title: 'Collection Information',
            subtitle: _buildCollectionInformationSubtitle(pop),
            icon: Icons.inventory_2_outlined,
            initiallyExpanded: false,
            badge: AtlasExpandableBadge(
              label: _buildCollectionCompletionLabel(pop),
              icon: _isCollectionInformationComplete(pop)
                  ? Icons.task_alt_rounded
                  : Icons.pending_actions_rounded,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Basic Information',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                _DetailRow(
                  label: 'Number',
                  value: pop.number,
                ),
                _DetailRow(
                  label: 'Category',
                  value: pop.category,
                ),
                _DetailRow(
                  label: 'Series',
                  value: pop.series,
                ),
                _DetailRow(
                  label: 'Edition',
                  value: pop.edition,
                ),
                _DetailRow(
                  label: 'Owner',
                  value: pop.owner,
                ),

                const SizedBox(height: AtlasSpacing.lg),

                Text(
                  'Collector Identity',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                _IdentityBadgeWrap(
                  badges: intelligence.identityBadges,
                ),
                const SizedBox(height: AtlasSpacing.md),
                _DetailRow(
                  label: 'Variant',
                  value: pop.variant,
                ),
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
                _DetailRow(
                  label: 'Signature',
                  value: pop.signature,
                ),

                const SizedBox(height: AtlasSpacing.lg),

                Text(
                  'Value & Condition',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.sm),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final useColumn = constraints.maxWidth < 360;

                    final quantityPanel = AtlasGlassPanel(
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
                                width: 32,
                                child: Text(
                                  '${pop.quantity}',
                                  textAlign: TextAlign.center,
                                  style: AtlasTypography.headingSmall.copyWith(
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
                                onPressed: () => _updateQuantity(
                                  pop.quantity + 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );

                    final valuePanel = AtlasMetricPanel(
                      label: 'Current Value',
                      value: valueLabel,
                      supportingText: pop.value <= 0
                          ? 'Add a value to improve collection analytics'
                          : 'Recorded collection value',
                      icon: Icons.attach_money_rounded,
                      accentColor: AtlasColors.vaultGold,
                    );

                    if (useColumn) {
                      return Column(
                        children: [
                          quantityPanel,
                          const SizedBox(height: AtlasSpacing.sm),
                          valuePanel,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: quantityPanel),
                        const SizedBox(width: AtlasSpacing.sm),
                        Expanded(child: valuePanel),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AtlasSpacing.sm),

                _DetailRow(
                  label: 'Price Paid',
                  value: paidLabel,
                ),
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

          AtlasTimelineCard(
            events: pop.timeline,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          AtlasTimelineIntelligenceCard(
            report: timelineReport,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          _PopRecentActivityCard(
            activities: popActivities,
            summary: activitySummary,
            onOpenTimeline: _openTimeline,
          ),
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
                AtlasActionRow(
                  title: 'Ask Atlas About This Pop',
                  description:
                  'Get contextual intelligence about this collectible and its place in your collection.',
                  icon: Icons.auto_awesome_rounded,
                  accentColor: AtlasColors.intelligenceBlue,
                  onTap: _openAskAtlas,
                ),
                const SizedBox(height: AtlasSpacing.sm),

                AtlasActionRow(
                  title: pop.value <= 0
                      ? 'Add Current Value'
                      : 'Update Current Value',
                  description: pop.value <= 0
                      ? 'Record a current value to improve collection analytics and tracking.'
                      : 'Update the recorded market value for this collectible.',
                  icon: pop.value <= 0
                      ? Icons.add_chart_rounded
                      : Icons.price_change_rounded,
                  accentColor: AtlasColors.vaultGold,
                  onTap: _editValue,
                ),
                const SizedBox(height: AtlasSpacing.sm),

                AtlasActionRow(
                  title: 'Edit Pop Details',
                  description:
                  'Update identity, condition, ownership, and other collectible information.',
                  icon: Icons.edit_rounded,
                  onTap: _editPop,
                ),
                const SizedBox(height: AtlasSpacing.sm),

                AtlasActionRow(
                  title: pop.isWishlist
                      ? 'Move to Owned Collection'
                      : 'Move to Wishlist',
                  description: pop.isWishlist
                      ? 'Mark this collectible as owned and move it out of your wishlist.'
                      : 'Move this collectible to your wishlist without removing its details.',
                  icon: pop.isWishlist
                      ? Icons.inventory_2_rounded
                      : Icons.favorite_border_rounded,
                  accentColor: pop.isWishlist
                      ? AtlasColors.success
                      : AtlasColors.warning,
                  onTap: _toggleWishlist,
                ),

                const SizedBox(height: AtlasSpacing.lg),

                Divider(
                  color: AtlasColors.textSecondary.withValues(
                    alpha: 0.18,
                  ),
                ),

                const SizedBox(height: AtlasSpacing.sm),

                AtlasActionRow(
                  title: 'Delete Pop',
                  description:
                  'Permanently remove this collectible from the current collection.',
                  icon: Icons.delete_outline_rounded,
                  accentColor: AtlasColors.danger,
                  onTap: _confirmDeletePop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _buildCollectionInformationSubtitle(Pop pop) {
  final completedFields = _collectionCompletedFieldCount(pop);
  const totalFields = 9;

  if (completedFields == totalFields) {
    return 'Ownership, identity, value, and condition are complete';
  }

  if (completedFields >= 6) {
    return 'Most collectible details have been recorded';
  }

  if (completedFields >= 3) {
    return 'Some collectible details still need attention';
  }

  return 'Add ownership, value, condition, and identity details';
}

String _buildCollectionCompletionLabel(Pop pop) {
  final completedFields = _collectionCompletedFieldCount(pop);
  const totalFields = 9;

  if (completedFields == totalFields) {
    return 'Complete';
  }

  return '$completedFields / $totalFields';
}

bool _isCollectionInformationComplete(Pop pop) {
  return _collectionCompletedFieldCount(pop) == 9;
}

int _collectionCompletedFieldCount(Pop pop) {
  final fields = <String>[
    pop.number,
    pop.category,
    pop.series,
    pop.edition,
    pop.owner,
    pop.itemCondition,
    pop.boxCondition,
  ];

  var completed = fields.where(_hasMeaningfulDetailValue).length;

  if (pop.value > 0) {
    completed++;
  }

  if (_hasCollectorIdentity(pop)) {
    completed++;
  }

  return completed;
}

bool _hasCollectorIdentity(Pop pop) {
  return <String>[
    pop.variant,
    pop.retailExclusive,
    pop.eventSticker,
    pop.limitedEdition,
    pop.signature,
  ].any(_hasMeaningfulDetailValue);
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

class _PopRecentActivityCard extends StatelessWidget {
  const _PopRecentActivityCard({
    required this.activities,
    required this.summary,
    required this.onOpenTimeline,
  });

  final List<Activity> activities;
  final PopActivitySummary summary;
  final VoidCallback onOpenTimeline;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: 'Recent Activity',
            subtitle: activities.isEmpty
                ? 'No recorded changes for this collectible yet'
                : 'Latest recorded changes for this collectible',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: AtlasSpacing.lg),

          AtlasInsightPanel(
            eyebrow: summary.hasActivity
                ? '${summary.activityCount} recorded '
                '${summary.activityCount == 1 ? 'event' : 'events'}'
                : 'Activity Intelligence',
            title: summary.title,
            message: summary.summary,
            icon: Icons.auto_awesome_rounded,
            tone: AtlasInsightPanelTone.intelligence,
          ),

          const SizedBox(height: AtlasSpacing.md),

          if (activities.isEmpty)
          const SizedBox(height: AtlasSpacing.md),
          if (activities.isEmpty)
            const AtlasEmptyState(
              eyebrow: 'Timeline',
              title: 'No activity yet',
              message:
              'Value updates, quantity changes, edits, and ownership moves will appear here.',
              icon: Icons.history_toggle_off_rounded,
              compact: true,
            )
          else
            ...activities.map(
                  (activity) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AtlasSpacing.sm,
                ),
                    child: AtlasActionRow(
                      title: _activityTitle(
                        activity.action,
                      ),
                      description:
                      '${activity.details}\n${_formatActivityTime(activity.timestamp)}',
                      icon: _activityIcon(
                        activity.action,
                      ),
                      accentColor: AtlasColors.vaultGold,
                      showChevron: false,
                      compact: true,
                    ),
              ),
            ),
          const SizedBox(height: AtlasSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenTimeline,
              icon: const Icon(Icons.timeline_rounded),
              label: const Text('View Full Timeline'),
            ),
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
  const _IdentityBadgeWrap({
    required this.badges,
  });

  final List<PopIdentityBadgeData> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const AtlasChip(label: 'Common / Standard');
    }

    return Wrap(
      spacing: AtlasSpacing.sm,
      runSpacing: AtlasSpacing.sm,
      children: badges
          .map(
            (badge) => AtlasChip(
          label: badge.displayLabel,
        ),
      )
          .toList(),
    );
  }
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
bool _activityMatchesPop(
    Activity activity,
    Pop pop,
    ) {
  final activityPopId = activity.popId.trim();
  final popId = pop.id.trim();

  if (activityPopId.isNotEmpty && popId.isNotEmpty) {
    return activityPopId == popId;
  }

  final activityName = activity.popName.trim().toLowerCase();
  final popName = pop.name.trim().toLowerCase();

  if (activityName != popName) {
    return false;
  }

  final activityNumber = activity.popNumber.trim().toLowerCase();
  final popNumber = pop.number.trim().toLowerCase();

  if (activityNumber.isEmpty || popNumber.isEmpty) {
    return true;
  }

  return activityNumber == popNumber;
}

String _activityTitle(String action) {
  switch (action) {
    case 'value_updated':
      return 'Value Updated';
    case 'quantity_updated':
    case 'quantity_increased':
      return 'Quantity Updated';
    case 'wishlist_added':
      return 'Moved to Wishlist';
    case 'wishlist_removed':
      return 'Moved to Owned';
    case 'pop_updated':
      return 'Pop Updated';
    case 'pop_added':
      return 'Pop Added';
    case 'pop_deleted':
      return 'Pop Deleted';
    default:
      return 'Vault Activity';
  }
}

IconData _activityIcon(String action) {
  switch (action) {
    case 'value_updated':
      return Icons.attach_money_rounded;
    case 'quantity_updated':
    case 'quantity_increased':
      return Icons.format_list_numbered_rounded;
    case 'wishlist_added':
      return Icons.favorite_rounded;
    case 'wishlist_removed':
      return Icons.inventory_2_rounded;
    case 'pop_updated':
      return Icons.edit_rounded;
    case 'pop_added':
      return Icons.add_circle_outline_rounded;
    case 'pop_deleted':
      return Icons.delete_outline_rounded;
    default:
      return Icons.history_rounded;
  }
}

String _formatActivityTime(DateTime timestamp) {
  final difference = DateTime.now().difference(timestamp);

  if (difference.inMinutes < 1) {
    return 'Now';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }

  return '${difference.inDays}d ago';
}