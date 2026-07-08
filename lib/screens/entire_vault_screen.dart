import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../atlas/repositories/vault_repository.dart';
import '../models/pop.dart';
import '../services/app_state.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_spacing.dart';
import '../theme/atlas_typography.dart';
import '../widgets/atlas/atlas_glass_card.dart';
import '../widgets/atlas/atlas_glass_panel.dart';
import '../widgets/vault_scroll_view.dart';

class EntireVaultScreen extends StatefulWidget {
  const EntireVaultScreen({super.key});

  @override
  State<EntireVaultScreen> createState() => _EntireVaultScreenState();
}

class _EntireVaultScreenState extends State<EntireVaultScreen> {
  final _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const repository = VaultRepository();

    final pops = repository.allPops(appState);
    final filteredPops = _filterPops(pops);

    final totalValue = pops.fold<double>(
      0,
          (total, pop) => total + pop.value,
    );
    final missingValueCount = pops.where((pop) => pop.value <= 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entire Vault'),
      ),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entire Vault',
                  style: AtlasTypography.headingLarge,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Review every Pop currently saved in your collection.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                AtlasGlassPanel(
                  child: Row(
                    children: [
                      Expanded(
                        child: _VaultSummaryItem(
                          value: '${pops.length}',
                          label: 'Pops',
                        ),
                      ),
                      Expanded(
                        child: _VaultSummaryItem(
                          value: '\$${totalValue.toStringAsFixed(0)}',
                          label: 'Value',
                        ),
                      ),
                      Expanded(
                        child: _VaultSummaryItem(
                          value: '$missingValueCount',
                          label: 'Need Value',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _VaultSearchCard(
            controller: _searchController,
            resultCount: filteredPops.length,
            totalCount: pops.length,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onClear: () {
              _searchController.clear();

              setState(() {
                _searchQuery = '';
              });
            },
          ),
          const SizedBox(height: AtlasSpacing.lg),
          if (pops.isEmpty)
            const _EmptyVaultCard()
          else if (filteredPops.isEmpty)
            const _NoSearchResultsCard()
          else
            _VaultPopListCard(
              pops: filteredPops,
            ),
        ],
      ),
    );
  }

  List<Pop> _filterPops(List<Pop> pops) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return pops;
    }

    return pops.where((pop) {
      final name = pop.name.toLowerCase();
      final number = pop.number.toLowerCase();
      final category = pop.category.toLowerCase();

      return name.contains(query) ||
          number.contains(query) ||
          category.contains(query);
    }).toList();
  }
}

class _VaultSearchCard extends StatelessWidget {
  const _VaultSearchCard({
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
    final hasSearch = controller.text.trim().isNotEmpty;

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Vault',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search by name, number, or category...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: hasSearch
                  ? IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: onChanged,
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

class _VaultSummaryItem extends StatelessWidget {
  const _VaultSummaryItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AtlasTypography.headingSmall.copyWith(
            color: AtlasColors.vaultGold,
          ),
        ),
        const SizedBox(height: AtlasSpacing.xs),
        Text(
          label,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EmptyVaultCard extends StatelessWidget {
  const _EmptyVaultCard();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Text(
        'Your vault is ready. Add your first Pop to begin building your collection.',
        style: AtlasTypography.bodyMedium.copyWith(
          color: AtlasColors.textSecondary,
        ),
      ),
    );
  }
}

class _NoSearchResultsCard extends StatelessWidget {
  const _NoSearchResultsCard();

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Text(
        'No Pops matched your search. Try a different name, number, or category.',
        style: AtlasTypography.bodyMedium.copyWith(
          color: AtlasColors.textSecondary,
        ),
      ),
    );
  }
}

class _VaultPopListCard extends StatelessWidget {
  const _VaultPopListCard({
    required this.pops,
  });

  final List<Pop> pops;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vault List',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          ...pops.map(
                (pop) => Padding(
              padding: const EdgeInsets.only(bottom: AtlasSpacing.sm),
              child: _VaultPopTile(pop: pop),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultPopTile extends StatelessWidget {
  const _VaultPopTile({
    required this.pop,
  });

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final numberLabel = pop.number.trim().isEmpty ? 'No #' : '#${pop.number}';
    final categoryLabel =
    pop.category.trim().isEmpty ? 'No category' : pop.category.trim();
    final valueLabel =
    pop.value <= 0 ? 'Value needed' : '\$${pop.value.toStringAsFixed(0)}';

    return AtlasGlassPanel(
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pop.name,
                  style: AtlasTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  '$numberLabel • $categoryLabel',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AtlasSpacing.md),
          Text(
            valueLabel,
            style: AtlasTypography.bodySmall.copyWith(
              color:
              pop.value <= 0 ? AtlasColors.textSecondary : AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}