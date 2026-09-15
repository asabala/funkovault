import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/repositories/vault_repository.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../vault/duplicate_review/duplicate_review_engine.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/components/atlas_chip.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/vault/components/vault_pop_tile.dart';
import '../pop/edit_pop_screen.dart';

class DuplicateGroupReviewScreen extends StatelessWidget {
  const DuplicateGroupReviewScreen({
    super.key,
    required this.groupKey,
    this.collectionName,
  });

  final String groupKey;
  final String? collectionName;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const repository = VaultRepository();
    const duplicateReviewEngine = DuplicateReviewEngine();

    final scopedPops = repository.pops(
      appState,
      collectionName: collectionName,
    );

    final groups = duplicateReviewEngine.buildGroups(scopedPops);

    final group = _findGroup(groups, groupKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Duplicate Group')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AtlasSpacing.md,
            AtlasSpacing.md,
            AtlasSpacing.md,
            100,
          ),
          child: group == null
              ? const _ResolvedDuplicateGroupView()
              : _ActiveDuplicateGroupView(
                  group: group,
                  onEditPop: (pop) {
                    _openEditor(context, pop);
                  },
                  onAddValue: (pop) {
                    _openValueEditor(context, pop);
                  },
                  onConsolidate: () {
                    _confirmConsolidation(context, group);
                  },
                ),
        ),
      ),
    );
  }

  DuplicateReviewGroup? _findGroup(
    List<DuplicateReviewGroup> groups,
    String key,
  ) {
    for (final group in groups) {
      if (group.key == key) {
        return group;
      }
    }

    return null;
  }

  String? _resolveCollectionName(BuildContext context, Pop pop) {
    final appState = context.read<AppState>();

    final explicitCollectionName = collectionName;

    if (explicitCollectionName != null) {
      if (!appState.hasCollection(explicitCollectionName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not edit this Pop because its collection no longer exists.',
            ),
          ),
        );

        return null;
      }

      return explicitCollectionName;
    }

    final collectionNames = appState.collectionNamesContainingPop(pop);

    if (collectionNames.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not edit this Pop because its collection could not be resolved safely.',
          ),
        ),
      );

      return null;
    }

    return collectionNames.single;
  }

  Future<void> _openEditor(BuildContext context, Pop pop) async {
    final targetCollectionName = _resolveCollectionName(context, pop);

    if (targetCollectionName == null) {
      return;
    }

    await Navigator.push<Pop>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditPopScreen(pop: pop, collectionName: targetCollectionName),
      ),
    );
  }

  Future<void> _openValueEditor(BuildContext context, Pop pop) async {
    final targetCollectionName = _resolveCollectionName(context, pop);

    if (targetCollectionName == null) {
      return;
    }

    await Navigator.push<Pop>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPopScreen(
          pop: pop,
          collectionName: targetCollectionName,
          focusValueField: true,
        ),
      ),
    );
  }

  Future<void> _confirmConsolidation(
    BuildContext context,
    DuplicateReviewGroup group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Consolidate Matching Copies?'),
          content: Text(
            'Atlas will combine ${group.itemCount} matching records into one '
            'record with a total quantity of ${group.totalQuantity}. '
            'The extra records will be removed. This only applies to this '
            'review group.',
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
              icon: const Icon(Icons.merge_rounded),
              label: const Text('Consolidate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final appState = context.read<AppState>();

    final succeeded = await appState.consolidateDuplicateGroup(
      group.pops.map((pop) => pop.id).toList(),
      collectionName: collectionName,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succeeded
              ? 'Matching copies were consolidated successfully.'
              : 'Atlas could not consolidate this group. Review the records and try again.',
        ),
      ),
    );
  }
}

class _ActiveDuplicateGroupView extends StatelessWidget {
  const _ActiveDuplicateGroupView({
    required this.group,
    required this.onEditPop,
    required this.onAddValue,
    required this.onConsolidate,
  });

  final DuplicateReviewGroup group;
  final ValueChanged<Pop> onEditPop;
  final ValueChanged<Pop> onAddValue;
  final VoidCallback onConsolidate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtlasGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AtlasSectionHeader(
                title: '${group.name} ${group.number}',
                subtitle:
                    '${group.itemCount} possible duplicate '
                    'item${group.itemCount == 1 ? '' : 's'} detected.',
                icon: Icons.content_copy_rounded,
                titleStyle: AtlasTypography.headingLarge,
              ),
              const SizedBox(height: AtlasSpacing.lg),
              Text(
                'These records currently share the same collectible identity. '
                'Compare each saved copy before consolidating.',
                style: AtlasTypography.bodySmall.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: AtlasSpacing.md),
        const AtlasInfoBanner(
          icon: Icons.shield_outlined,
          title: 'Review Before Making Changes',
          message:
              'Only consolidate records when they represent identical copies. '
              'Different variants, stickers, exclusives, signatures, or '
              'limited-edition releases should remain separate Pops.',
        ),
        const SizedBox(height: AtlasSpacing.md),
        AtlasGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AtlasSectionHeader(
                title: 'Matching Copies',
                subtitle:
                    'These records currently describe the same collectible, '
                    'owner, and collection status.',
                icon: Icons.layers_rounded,
              ),
              const SizedBox(height: AtlasSpacing.md),

              Wrap(
                spacing: AtlasSpacing.sm,
                runSpacing: AtlasSpacing.sm,
                children: [
                  AtlasStatusChip(
                    label: '${group.itemCount} Saved Records',
                    icon: Icons.layers_rounded,
                    size: AtlasStatusChipSize.compact,
                  ),
                  AtlasStatusChip(
                    label:
                        '${group.totalQuantity} Total ${group.totalQuantity == 1 ? 'Copy' : 'Copies'}',
                    icon: Icons.inventory_2_outlined,
                    size: AtlasStatusChipSize.compact,
                  ),
                ],
              ),

              const SizedBox(height: AtlasSpacing.md),

              const AtlasInfoBanner(
                icon: Icons.merge_rounded,
                title: 'How Consolidation Works',
                message:
                    'Consolidation keeps one record and combines the quantities. Only use this when these are truly identical copies.',
              ),

              const SizedBox(height: AtlasSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onConsolidate,
                  icon: const Icon(Icons.merge_rounded),
                  label: const Text('Consolidate Copies'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AtlasSpacing.lg),
        const AtlasSectionHeader(
          title: 'Compare Saved Pops',
          subtitle:
              'Open each Pop to correct missing or inaccurate information.',
          icon: Icons.compare_rounded,
        ),
        const SizedBox(height: AtlasSpacing.md),
        ...group.pops.asMap().entries.map((entry) {
          final position = entry.key + 1;
          final pop = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: AtlasSpacing.md),
            child: _DuplicatePopReviewCard(
              position: position,
              totalCount: group.itemCount,
              pop: pop,
              onEdit: () => onEditPop(pop),
              onAddValue: pop.value <= 0 ? () => onAddValue(pop) : null,
            ),
          );
        }),
      ],
    );
  }
}

class _DuplicatePopReviewCard extends StatelessWidget {
  const _DuplicatePopReviewCard({
    required this.position,
    required this.totalCount,
    required this.pop,
    required this.onEdit,
    required this.onAddValue,
  });

  final int position;
  final int totalCount;
  final Pop pop;
  final VoidCallback onEdit;
  final VoidCallback? onAddValue;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Item $position of $totalCount',
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AtlasChip(
                label: pop.value > 0
                    ? '\$${pop.value.toStringAsFixed(2)}'
                    : 'Needs Value',
                icon: pop.value > 0
                    ? Icons.attach_money_rounded
                    : Icons.warning_amber_rounded,
                size: AtlasChipSize.compact,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          VaultPopTile(pop: pop, showImage: true),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Details'),
                ),
              ),
              if (onAddValue != null) ...[
                const SizedBox(width: AtlasSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAddValue,
                    icon: const Icon(Icons.attach_money_rounded),
                    label: const Text('Add Value'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ResolvedDuplicateGroupView extends StatelessWidget {
  const _ResolvedDuplicateGroupView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AtlasEmptyState(
          icon: Icons.task_alt_rounded,
          title: 'Duplicate Group Resolved',
          message:
              'This group no longer qualifies as a possible duplicate review '
              'group. The records may have been corrected or consolidated.',
        ),
        const SizedBox(height: AtlasSpacing.md),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Return to Entire Vault'),
        ),
      ],
    );
  }
}
