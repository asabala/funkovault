import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/coordinator/atlas_dashboard.dart';
import '../../atlas/coordinator/atlas_dashboard_model.dart';
import '../../atlas/engines/context/vault_context_explainer_engine.dart';
import '../../atlas/screens/atlas_timeline_screen.dart';
import '../../navigation/atlas_navigation_controller.dart';
import '../../security/auth_provider.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../vault/collector_vault_screen.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/atlas_stat_tile.dart';
import '../../widgets/home/atlas_unified_search_launcher.dart';
import '../../widgets/vault/vault_ask_atlas_bottom_sheet.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import '../search/atlas_collector_search_screen.dart';
import '../vault/entire_vault_screen.dart';

class AtlasHomeScreen extends StatelessWidget {
  const AtlasHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    final AuthProvider authProvider = context.watch<AuthProvider>();

    final profile = appState.collectorProfile;

    final bool isLoggedIn = authProvider.isLoggedIn;

    final String accountDisplayName =
        authProvider.controller.state.displayName?.trim().isNotEmpty == true
        ? authProvider.controller.state.displayName!.trim()
        : profile.displayName;

    const AtlasDashboard dashboardBuilder = AtlasDashboard();

    final AtlasDashboardModel dashboard = dashboardBuilder.build(appState);

    final DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Pulse'),
        actions: [
          IconButton(
            tooltip: isLoggedIn
                ? 'Signed in as $accountDisplayName'
                : 'Guest collector',
            onPressed: () {
              _openVault(context);
            },
            icon: _HomeAvatar(displayName: profile.displayName),
          ),
          const SizedBox(width: AtlasSpacing.sm),
        ],
      ),
      body: VaultScrollView(
        children: [
          _HomePulseSummary(
            greeting: _greeting(profile.displayName, now),
            totalPops: dashboard.totalPops,
            totalValue: dashboard.totalValue,
            confidence: dashboard.confidence.score,
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasUnifiedSearchLauncher(
            hintText: 'Search Collection...',
            onSearchPressed: () {
              _openCollectorSearch(context);
            },
            onBarcodePressed: () {
              _openScanner(context);
            },
          ),
          const SizedBox(height: AtlasSpacing.md),
          _HomeAskAtlasCard(
            onAskAtlas: () {
              _openAskAtlas(context, dashboard);
            },
          ),
          const SizedBox(height: AtlasSpacing.md),
          _HomeRecentUpdatesCard(
            hasActivity: appState.recentActivities.isNotEmpty,
            latestActivity: appState.recentActivities.isEmpty
                ? null
                : appState.recentActivities.first.details,
            onOpenTimeline: () {
              _openTimeline(context);
            },
            onOpenVault: () {
              _openVault(context);
            },
          ),
        ],
      ),
    );
  }

  static void _openCollectorSearch(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return const AtlasCollectorSearchScreen();
        },
      ),
    );
  }

  static void _openScanner(BuildContext context) {
    context.read<AtlasNavigationController>().goTo(2);
  }

  static void _openTimeline(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return const AtlasTimelineScreen();
        },
      ),
    );
  }

  static void _openAskAtlas(
    BuildContext context,
    AtlasDashboardModel dashboard,
  ) {
    const VaultContextExplainerEngine explainerEngine =
        VaultContextExplainerEngine();

    VaultAskAtlasBottomSheet.show(
      context: context,
      dashboard: dashboard,
      explainerEngine: explainerEngine,
      onOpenVaultRequest: (VaultNavigationRequest request) {
        _openRequestedVault(context, request);
      },
    );
  }

  static void _openRequestedVault(
    BuildContext context,
    VaultNavigationRequest request,
  ) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return EntireVaultScreen(
            initialFilterKey: request.filterKey,
            initialSearchQuery: request.searchQuery,
            initialMinimumValue: request.minimumValue,
            initialMaximumValue: request.maximumValue,
            initialSortKey: request.sortKey,
          );
        },
      ),
    );
  }

  static void _openVault(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return const CollectorVaultScreen();
        },
      ),
    );
  }

  static String _greeting(String name, DateTime now) {
    if (now.hour < 12) {
      return 'Good Morning $name';
    }

    if (now.hour < 17) {
      return 'Good Afternoon $name';
    }

    return 'Good Evening $name';
  }
}

class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final String initial = displayName.trim().isEmpty
        ? 'A'
        : displayName.trim()[0].toUpperCase();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AtlasColors.vaultGold,
          child: Text(
            initial,
            style: const TextStyle(
              color: AtlasColors.background,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
              border: Border.all(color: AtlasColors.background, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomePulseSummary extends StatelessWidget {
  const _HomePulseSummary({
    required this.greeting,
    required this.totalPops,
    required this.totalValue,
    required this.confidence,
  });

  final String greeting;
  final int totalPops;
  final double totalValue;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: AtlasTypography.headingLarge),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Here’s your collection at a glance.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AtlasStatTile(
                  icon: Icons.inventory_2_outlined,
                  value: '$totalPops',
                  label: 'Pops',
                ),
              ),
              Expanded(
                child: AtlasStatTile(
                  icon: Icons.attach_money,
                  value: '\$${totalValue.toStringAsFixed(0)}',
                  label: 'Value',
                ),
              ),
              Expanded(
                child: AtlasStatTile(
                  icon: Icons.health_and_safety_outlined,
                  value: '${confidence.toStringAsFixed(0)}%',
                  label: 'Confidence',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeAskAtlasCard extends StatelessWidget {
  const _HomeAskAtlasCard({required this.onAskAtlas});

  final VoidCallback onAskAtlas;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AtlasColors.vaultGold,
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Expanded(
                child: Text('Ask Atlas', style: AtlasTypography.headingSmall),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            'Ask trusted questions about your Vault, value, missing data, and collection health.',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAskAtlas,
              icon: const Icon(Icons.psychology_alt_rounded),
              label: const Text('Ask Atlas About My Vault'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeRecentUpdatesCard extends StatelessWidget {
  const _HomeRecentUpdatesCard({
    required this.hasActivity,
    required this.latestActivity,
    required this.onOpenTimeline,
    required this.onOpenVault,
  });

  final bool hasActivity;
  final String? latestActivity;
  final VoidCallback onOpenTimeline;
  final VoidCallback onOpenVault;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Updates',
                  style: AtlasTypography.headingSmall,
                ),
              ),
              TextButton(
                onPressed: onOpenTimeline,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          AtlasGlassPanel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasActivity
                      ? Icons.check_circle_outline_rounded
                      : Icons.history_toggle_off_rounded,
                  color: AtlasColors.vaultGold,
                ),
                const SizedBox(width: AtlasSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasActivity
                            ? 'Latest collection update'
                            : 'Your collection is ready',
                        style: AtlasTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AtlasSpacing.xs),
                      Text(
                        hasActivity
                            ? latestActivity ?? 'Your Vault was updated.'
                            : 'Add or import collectibles to start building your Atlas history.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.sm),
          InkWell(
            onTap: onOpenVault,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AtlasSpacing.sm,
                vertical: AtlasSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    color: AtlasColors.vaultGold,
                    size: 22,
                  ),
                  const SizedBox(width: AtlasSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue Your Collection',
                          style: AtlasTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Organize collectibles and review your Vault Rooms.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AtlasTypography.bodySmall.copyWith(
                            color: AtlasColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AtlasColors.intelligenceBlue,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
