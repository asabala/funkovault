import 'package:flutter/material.dart';

import '../../atlas/live_sniffer/atlas_live_sniffer_controller.dart';
import '../../atlas/live_sniffer/atlas_live_sniffer_status.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class AtlasLiveSnifferScreen extends StatefulWidget {
  const AtlasLiveSnifferScreen({super.key});

  @override
  State<AtlasLiveSnifferScreen> createState() => _AtlasLiveSnifferScreenState();
}

class _AtlasLiveSnifferScreenState extends State<AtlasLiveSnifferScreen>
    with WidgetsBindingObserver {
  late final AtlasLiveSnifferController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AtlasLiveSnifferController()..addListener(_handleChanged);
    _controller.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_handleChanged)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.refresh();
    }
  }

  void _handleChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AtlasLiveSnifferStatus status = _controller.status;

    return Scaffold(
      appBar: AppBar(title: const Text('Atlas Live Sniffer')),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            accentColor: AtlasColors.intelligenceBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AtlasSectionHeader(
                  title: '📡 Android Live Sniffer',
                  subtitle:
                      'Floating collector intelligence while you browse another app.',
                  icon: Icons.picture_in_picture_alt_rounded,
                  accentColor: AtlasColors.intelligenceBlue,
                  trailing: AtlasStatusChip(
                    label: status.isCapturing ? 'Live' : 'Stopped',
                    icon: status.isCapturing
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_outlined,
                    accentColor: status.isCapturing
                        ? AtlasColors.success
                        : AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.lg),
                const AtlasInfoBanner(
                  title: '6C Foundation',
                  message:
                      'This checkpoint establishes Android screen-capture, foreground-service, and floating-HUD lifecycle. Recognition and live pricing are connected in the next 6C checkpoint.',
                  icon: Icons.construction_rounded,
                  accentColor: AtlasColors.intelligenceBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _PermissionCard(
            title: 'Display over other apps',
            description:
                'Allows the small Atlas HUD to remain visible above marketplaces and browsers.',
            granted: status.overlayPermissionGranted,
            actionLabel: 'Grant Overlay Permission',
            onPressed: _controller.busy
                ? null
                : _controller.requestOverlayPermission,
          ),
          const SizedBox(height: AtlasSpacing.md),
          _PermissionCard(
            title: 'Notifications',
            description:
                'Android requires a persistent foreground-service notification while screen capture is active.',
            granted: status.notificationPermissionGranted,
            actionLabel: 'Grant Notification Permission',
            onPressed: _controller.busy
                ? null
                : _controller.requestNotificationPermission,
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasGlassCard(
            accentColor: status.isCapturing
                ? AtlasColors.success
                : AtlasColors.intelligenceBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AtlasSectionHeader(
                  title: 'Live Session',
                  subtitle: status.supported
                      ? 'Android will ask which screen or app Atlas may observe.'
                      : '6C is Android-only. iPhone/iPad support arrives in Scanner 6D.',
                  icon: Icons.screen_share_outlined,
                  accentColor: status.isCapturing
                      ? AtlasColors.success
                      : AtlasColors.intelligenceBlue,
                ),
                const SizedBox(height: AtlasSpacing.md),
                Wrap(
                  spacing: AtlasSpacing.sm,
                  runSpacing: AtlasSpacing.sm,
                  children: [
                    AtlasStatusChip(
                      label: status.overlayPermissionGranted
                          ? 'Overlay Ready'
                          : 'Overlay Needed',
                      icon: status.overlayPermissionGranted
                          ? Icons.check_circle_outline_rounded
                          : Icons.warning_amber_rounded,
                      accentColor: status.overlayPermissionGranted
                          ? AtlasColors.success
                          : AtlasColors.warning,
                    ),
                    AtlasStatusChip(
                      label: status.notificationPermissionGranted
                          ? 'Notifications Ready'
                          : 'Notification Needed',
                      icon: status.notificationPermissionGranted
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      accentColor: status.notificationPermissionGranted
                          ? AtlasColors.success
                          : AtlasColors.warning,
                    ),
                    AtlasStatusChip(
                      label: status.isOverlayVisible
                          ? 'HUD Visible'
                          : 'HUD Hidden',
                      icon: Icons.picture_in_picture_alt_rounded,
                      accentColor: status.isOverlayVisible
                          ? AtlasColors.success
                          : AtlasColors.textSecondary,
                    ),
                  ],
                ),
                if (status.lastError != null) ...[
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasInfoBanner(
                    title: 'Android reported an issue',
                    message: status.lastError!,
                    icon: Icons.error_outline_rounded,
                    accentColor: AtlasColors.danger,
                  ),
                ],
                if (_controller.message != null) ...[
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasInfoBanner(
                    title: 'Atlas Live Sniffer',
                    message: _controller.message!,
                    icon: Icons.info_outline_rounded,
                    accentColor: AtlasColors.intelligenceBlue,
                  ),
                ],
                const SizedBox(height: AtlasSpacing.lg),
                if (status.isCapturing)
                  FilledButton.icon(
                    onPressed: _controller.busy ? null : _controller.stop,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Stop Live Sniffer'),
                  )
                else
                  FilledButton.icon(
                    key: const ValueKey('start-live-sniffer'),
                    onPressed: _controller.busy ? null : _controller.start,
                    icon: _controller.busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_circle_outline_rounded),
                    label: Text(
                      _controller.busy ? 'Working...' : 'Start Live Sniffer',
                    ),
                  ),
                const SizedBox(height: AtlasSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _controller.busy ? null : _controller.refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh Status'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.title,
    required this.description,
    required this.granted,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String description;
  final bool granted;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color accent = granted ? AtlasColors.success : AtlasColors.warning;

    return AtlasGlassCard(
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: title,
            subtitle: description,
            icon: granted
                ? Icons.check_circle_outline_rounded
                : Icons.admin_panel_settings_outlined,
            accentColor: accent,
            trailing: AtlasStatusChip(
              label: granted ? 'Ready' : 'Required',
              icon: granted ? Icons.check_rounded : Icons.warning_amber_rounded,
              accentColor: accent,
            ),
          ),
          if (!granted) ...[
            const SizedBox(height: AtlasSpacing.md),
            OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.settings_outlined),
              label: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}
