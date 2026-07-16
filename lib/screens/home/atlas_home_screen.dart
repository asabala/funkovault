import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/coordinator/atlas_dashboard.dart';
import '../../atlas/coordinator/atlas_dashboard_model.dart';
import '../../atlas/engines/vault_context_explainer_engine.dart';
import '../../atlas/screens/atlas_timeline_screen.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../vault/collector_vault_screen.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/atlas_stat_tile.dart';
import '../../widgets/home/atlas_pulse_card.dart';
import '../../widgets/home/continue_journey_card.dart';
import '../../widgets/vault/vault_ask_atlas_bottom_sheet.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import '../vault/entire_vault_screen.dart';

class AtlasHomeScreen extends StatelessWidget {
  const AtlasHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.collectorProfile;

    const dashboardBuilder = AtlasDashboard();

    final AtlasDashboardModel dashboard = dashboardBuilder.build(appState);

    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Pulse'),
        actions: [
          IconButton(
            tooltip: 'Signed in as ${profile.displayName}',
            onPressed: () => _openVault(context),
            icon: _HomeAvatar(
              displayName: profile.displayName,
            ),
          ),
          const SizedBox(width: AtlasSpacing.sm),
        ],
      ),
      body: VaultScrollView(
        children: [
          AtlasPulseCard(
            greeting: _greeting(profile.displayName, now),
            dateLabel: _dateLabel(now),
            timeLabel: _timeLabel(now),
            status: _statusLabel(dashboard.confidence.score),
            summary: _summaryLabel(
              totalPops: dashboard.totalPops,
              confidence: dashboard.confidence.score,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _HomeAccountStatusCard(
            displayName: profile.displayName,
            collectorTitle: profile.collectorTitle,
            totalPops: dashboard.totalPops,
            confidence: dashboard.confidence.score,
            onOpenVault: () => _openVault(context),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _HomeStatsCard(
            totalPops: dashboard.totalPops,
            totalValue: dashboard.totalValue,
            confidence: dashboard.confidence.score,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _HomeAskAtlasCard(
            onAskAtlas: () => _openAskAtlas(
              context,
              dashboard,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          ContinueJourneyCard(
            title: 'Collector Vault',
            subtitle:
            'Continue organizing your collection and reviewing your Vault Rooms.',
            onContinue: () => _openVault(context),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _RecentActivityCard(
            hasActivity: appState.recentActivities.isNotEmpty,
            latestActivity: appState.recentActivities.isEmpty
                ? null
                : appState.recentActivities.first.details,
            onOpenTimeline: () => _openTimeline(context),
          ),
        ],
      ),
    );
  }

  static void _openTimeline(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AtlasTimelineScreen(),
      ),
    );
  }

  static void _openAskAtlas(
      BuildContext context,
      AtlasDashboardModel dashboard,
      ) {
    const explainerEngine = VaultContextExplainerEngine();

    VaultAskAtlasBottomSheet.show(
      context: context,
      dashboard: dashboard,
      explainerEngine: explainerEngine,
      onOpenVaultFilter: (filterKey) {
        _openFilteredVault(
          context,
          filterKey,
        );
      },
    );
  }

  static void _openFilteredVault(
      BuildContext context,
      String filterKey,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntireVaultScreen(
          initialFilterKey: filterKey,
        ),
      ),
    );
  }

  static void _openVault(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CollectorVaultScreen(),
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

  static String _dateLabel(DateTime now) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[now.weekday - 1]}, '
        '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  static String _timeLabel(DateTime now) {
    final hour = now.hour == 0
        ? 12
        : now.hour > 12
        ? now.hour - 12
        : now.hour;

    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  static String _statusLabel(double confidence) {
    if (confidence >= 90) {
      return 'Atlas systems are operating with high confidence.';
    }

    if (confidence >= 75) {
      return 'Atlas is reading your Vault clearly.';
    }

    if (confidence >= 50) {
      return 'Atlas can improve with more collection details.';
    }

    return 'Atlas needs more Vault data to improve accuracy.';
  }

  static String _summaryLabel({
    required int totalPops,
    required double confidence,
  }) {
    if (totalPops == 0) {
      return 'Your Vault is ready. Add your first collectible to begin your collector journey.';
    }

    return 'Your Vault has $totalPops collectible'
        '${totalPops == 1 ? '' : 's'} with '
        '${confidence.toStringAsFixed(0)}% Atlas Confidence.';
  }
}

class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({
    required this.displayName,
  });

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final initial = displayName.trim().isEmpty
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
              border: Border.all(
                color: AtlasColors.background,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeAccountStatusCard extends StatelessWidget {
  const _HomeAccountStatusCard({
    required this.displayName,
    required this.collectorTitle,
    required this.totalPops,
    required this.confidence,
    required this.onOpenVault,
  });

  final String displayName;
  final String collectorTitle;
  final int totalPops;
  final double confidence;
  final VoidCallback onOpenVault;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Row(
        children: [
          const Icon(
            AtlasIcons.atlas,
            color: AtlasColors.vaultGold,
            size: 36,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signed in as $displayName',
                  style: AtlasTypography.headingSmall,
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  collectorTitle,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  '$totalPops Pops • '
                      '${confidence.toStringAsFixed(0)}% Atlas Confidence',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AtlasSpacing.md),
          OutlinedButton(
            onPressed: onOpenVault,
            child: const Text('Vault'),
          ),
        ],
      ),
    );
  }
}

class _HomeStatsCard extends StatelessWidget {
  const _HomeStatsCard({
    required this.totalPops,
    required this.totalValue,
    required this.confidence,
  });

  final int totalPops;
  final double totalValue;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: AtlasGlassPanel(
        child: Row(
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
      ),
    );
  }
}

class _HomeAskAtlasCard extends StatelessWidget {
  const _HomeAskAtlasCard({
    required this.onAskAtlas,
  });

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
                child: Text(
                  'Ask Atlas',
                  style: AtlasTypography.headingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            'Ask trusted questions about your Vault, collection value, cleanup priorities, missing values, and health.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAskAtlas,
              icon: const Icon(
                Icons.psychology_alt_rounded,
              ),
              label: const Text(
                'Ask Atlas About My Vault',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({
    required this.hasActivity,
    required this.latestActivity,
    required this.onOpenTimeline,
  });

  final bool hasActivity;
  final String? latestActivity;
  final VoidCallback onOpenTimeline;

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
                  'Latest Activity',
                  style: AtlasTypography.headingSmall,
                ),
              ),
              TextButton.icon(
                onPressed: onOpenTimeline,
                icon: const Icon(
                  Icons.timeline_rounded,
                  size: 18,
                ),
                label: const Text('View Timeline'),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasActivity
                      ? Icons.history_rounded
                      : Icons.history_toggle_off_rounded,
                  color: AtlasColors.vaultGold,
                ),
                const SizedBox(width: AtlasSpacing.md),
                Expanded(
                  child: Text(
                    hasActivity
                        ? latestActivity ?? 'Activity detected.'
                        : 'No recent activity yet. Add your first collectible to start building Atlas Memory.',
                    style: AtlasTypography.bodyMedium.copyWith(
                      color: AtlasColors.textSecondary,
                    ),
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