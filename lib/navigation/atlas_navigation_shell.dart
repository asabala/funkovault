import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../atlas/screens/atlas_intelligence_center.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_icons.dart';
import '../theme/atlas_typography.dart';
import 'atlas_bottom_navigation.dart';
import 'atlas_navigation_controller.dart';
import '../vault/collector_vault_screen.dart';

class AtlasNavigationShell extends StatelessWidget {
  const AtlasNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AtlasNavigationController(),
      child: const _AtlasNavigationShellView(),
    );
  }
}

class _AtlasNavigationShellView extends StatelessWidget {
  const _AtlasNavigationShellView();

  @override
  Widget build(BuildContext context) {
    final controller =
    context.watch<AtlasNavigationController>();

    final pages = [
      const AtlasIntelligenceCenter(),
      const CollectorVaultScreen(),

      const _ComingSoonPage(
        title: 'Smart Scanner',
        message: 'Barcode and image scanning are coming soon.',
        icon: Icons.qr_code_scanner,
      ),
      const _ComingSoonPage(
        title: 'Atlas Insights',
        message: 'Trends, growth, and intelligence will live here.',
        icon: AtlasIcons.trend,
      ),
      const _ComingSoonPage(
        title: 'Settings',
        message: 'Atlas preferences and app settings will live here.',
        icon: Icons.settings,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: controller.index,
        children: pages,
      ),
      bottomNavigationBar: AtlasBottomNavigation(
        currentIndex: controller.index,
        onTap: controller.goTo,
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtlasColors.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: AtlasColors.vaultGold,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AtlasTypography.headingLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AtlasTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}