import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/academy/atlas_academy_screen.dart';
import '../screens/home/atlas_home_screen.dart';
import '../screens/insights/atlas_insights_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../theme/atlas_colors.dart';
import '../theme/atlas_typography.dart';
import '../vault/collector_vault_screen.dart';
import 'atlas_bottom_navigation.dart';
import 'atlas_navigation_controller.dart';

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
    final controller = context.watch<AtlasNavigationController>();

    final pages = [
      const AtlasHomeScreen(),
      const CollectorVaultScreen(),
      const _ComingSoonPage(
        title: 'Smart Scanner',
        message: 'Barcode and image scanning are coming soon.',
        icon: Icons.qr_code_scanner,
      ),
      const AtlasInsightsScreen(),
      const AtlasAcademyScreen(),
      const SettingsScreen(),
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