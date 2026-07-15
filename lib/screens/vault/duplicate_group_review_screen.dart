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
import '../../widgets/vault/components/vault_pop_tile.dart';
import '../pop/edit_pop_screen.dart';

class DuplicateGroupReviewScreen extends StatelessWidget {
  const DuplicateGroupReviewScreen({
    super.key,
    required this.groupKey,
  });

  final String groupKey;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const repository = VaultRepository();
    const duplicateReviewEngine = DuplicateReviewEngine();

    final allPops = repository.allPops(appState);
    final groups = duplicateReviewEngine.buildGroups(allPops);
    final group = _findGroup(
      groups,
      groupKey,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Duplicate Group'),
      ),
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
              _openEditor(
                context,
                pop,
              );
            },
            onAddValue: (pop) {
              _openValueEditor(
                context,
                pop,
              );
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

  Future<void> _openEditor(
      BuildContext context,
      Pop pop,
      ) async {
    await Navigator.push<Pop>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPopScreen(
          pop: pop,
        ),
      ),
    );
  }

  Future<void> _openValueEditor(
      BuildContext context,
      Pop pop,
      ) async {
    await Navigator.push<Pop>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPopScreen(
          pop: pop,
          focusValueField: true,
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
  });

  final DuplicateReviewGroup group;
  final ValueChanged<Pop> onEditPop;
  final ValueChanged<Pop> onAddValue;

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
                '${group.itemCount} possible duplicate or variant '
                    'item${group.itemCount == 1 ? '' : 's'} detected.',
                icon: Icons.content_copy_rounded,
                titleStyle: AtlasTypography.headingLarge,
              ),
              if (group.differenceLabels.isNotEmpty) ...[
                const SizedBox(height: AtlasSpacing.lg),
                Text(
                  'Saved differences detected',
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Wrap(
                  spacing: AtlasSpacing.xs,
                  runSpacing: AtlasSpacing.xs,
                  children: group.differenceLabels
                      .map(
                        (label) => AtlasChip(
                      label: label,
                      icon: Icons.compare_arrows_rounded,
                      size: AtlasChipSize.compact,
                    ),
                  )
                      .toList(),
                ),
              ] else ...[
                const SizedBox(height: AtlasSpacing.lg),
                Text(
                  'Atlas did not detect differences in the saved variant '
                      'metadata. Compare the images, stickers, box details, '
                      'ownership information, and physical collectibles manually.',
                  style: AtlasTypography.bodySmall.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AtlasSpacing.md),
        const AtlasInfoBanner(
          icon: Icons.shield_outlined,
          title: 'Review Before Making Changes',
          message:
          'The same name and box number do not always mean the same '
              'collectible. Check Common versus Chase, stickers, exclusives, '
              'signatures, limited editions, and other variants. Atlas will '
              'not automatically merge or remove these Pops.',
        ),
        const SizedBox(height: AtlasSpacing.lg),
        AtlasSectionHeader(
          title: 'Compare Saved Pops',
          subtitle:
          'Open each Pop to correct missing or inaccurate information.',
          icon: Icons.compare_rounded,
        ),
        const SizedBox(height: AtlasSpacing.md),
        ...group.pops.asMap().entries.map(
              (entry) {
            final position = entry.key + 1;
            final pop = entry.value;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: AtlasSpacing.md,
              ),
              child: _DuplicatePopReviewCard(
                position: position,
                totalCount: group.itemCount,
                pop: pop,
                onEdit: () => onEditPop(pop),
                onAddValue: pop.value <= 0
                    ? () => onAddValue(pop)
                    : null,
              ),
            );
          },
        ),
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
          VaultPopTile(
            pop: pop,
            showImage: true,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  label: const Text(
                    'Edit Details',
                  ),
                ),
              ),
              if (onAddValue != null) ...[
                const SizedBox(width: AtlasSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAddValue,
                    icon: const Icon(
                      Icons.attach_money_rounded,
                    ),
                    label: const Text(
                      'Add Value',
                    ),
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
              'group. One or more saved details may have been corrected.',
        ),
        const SizedBox(height: AtlasSpacing.md),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          label: const Text(
            'Return to Entire Vault',
          ),
        ),
      ],
    );
  }
}