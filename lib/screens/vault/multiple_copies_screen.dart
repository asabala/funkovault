import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/repositories/vault_repository.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/atlas_stat_tile.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/atlas/components/atlas_empty_state.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/vault/components/vault_pop_tile.dart';
import '../pop/edit_pop_screen.dart';

class MultipleCopiesScreen extends StatelessWidget {
  const MultipleCopiesScreen({super.key, this.collectionName});

  final String? collectionName;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    const repository = VaultRepository();

    final multipleCopyPops =
        repository
            .pops(appState, collectionName: collectionName)
            .where((pop) => pop.quantity > 1)
            .toList()
          ..sort((a, b) => b.quantity.compareTo(a.quantity));

    final totalCopies = multipleCopyPops.fold<int>(
      0,
      (total, pop) => total + pop.quantity,
    );

    final extraCopies = multipleCopyPops.fold<int>(
      0,
      (total, pop) => total + (pop.quantity - 1),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Copies')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AtlasSectionHeader(
                      title: 'Multiple Copies Review',
                      subtitle:
                          'Review collectibles that represent more than one physical copy.',
                      icon: Icons.layers_rounded,
                      titleStyle: AtlasTypography.headingLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    AtlasGlassPanel(
                      child: Row(
                        children: [
                          Expanded(
                            child: AtlasStatTile(
                              value: '${multipleCopyPops.length}',
                              label: 'Records',
                            ),
                          ),
                          Expanded(
                            child: AtlasStatTile(
                              value: '$totalCopies',
                              label: 'Copies',
                            ),
                          ),
                          Expanded(
                            child: AtlasStatTile(
                              value: '$extraCopies',
                              label: 'Extra',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AtlasSpacing.md),
              const AtlasInfoBanner(
                icon: Icons.info_outline_rounded,
                title: 'How Quantity Works',
                message:
                    'Atlas keeps identical copies under one collectible record. '
                    'Quantity 2 means one primary copy plus one extra copy. '
                    'Edit the quantity only when the physical count is incorrect.',
              ),
              const SizedBox(height: AtlasSpacing.lg),
              if (multipleCopyPops.isEmpty)
                const AtlasEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No Multiple-Copy Records',
                  message:
                      'Every collectible currently has a quantity of one. '
                      'No consolidated copies need review.',
                )
              else
                ...multipleCopyPops.map(
                  (pop) => Padding(
                    padding: const EdgeInsets.only(bottom: AtlasSpacing.md),
                    child: _MultipleCopyCard(
                      pop: pop,
                      onEdit: () {
                        _openEditor(context, pop);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, Pop pop) async {
    final appState = context.read<AppState>();

    String? targetCollectionName = collectionName;

    if (targetCollectionName == null) {
      final collectionNames = appState.collectionNamesContainingPop(pop);

      if (collectionNames.length != 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not edit this Pop because its collection could not be resolved safely.',
            ),
          ),
        );

        return;
      }

      targetCollectionName = collectionNames.single;
    }

    if (!appState.hasCollection(targetCollectionName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not edit this Pop because its collection no longer exists.',
          ),
        ),
      );

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
}

class _MultipleCopyCard extends StatelessWidget {
  const _MultipleCopyCard({required this.pop, required this.onEdit});

  final Pop pop;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final extraCopyCount = pop.quantity - 1;

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pop.name} ${_numberLabel(pop.number)}',
                      style: AtlasTypography.headingSmall.copyWith(
                        color: AtlasColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      pop.collectorLabel,
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.vaultGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              AtlasStatusChip(
                label: 'Qty ${pop.quantity}',
                icon: Icons.layers_rounded,
                accentColor: AtlasColors.vaultGold,
                size: AtlasStatusChipSize.compact,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          VaultPopTile(pop: pop, showImage: true),
          const SizedBox(height: AtlasSpacing.md),
          AtlasInfoBanner(
            icon: Icons.add_box_outlined,
            title: 'Extra Copies',
            message:
                '$extraCopyCount extra '
                '${extraCopyCount == 1 ? 'copy is' : 'copies are'} '
                'represented by this record.',
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasActionRow(
            title: 'Edit Quantity',
            description:
                'Update the physical copy count represented by this collectible record.',
            icon: Icons.edit_outlined,
            accentColor: AtlasColors.vaultGold,
            onTap: onEdit,
          ),
        ],
      ),
    );
  }

  String _numberLabel(String number) {
    final cleaned = number.trim();

    if (cleaned.isEmpty) {
      return '';
    }

    return '#$cleaned';
  }
}
