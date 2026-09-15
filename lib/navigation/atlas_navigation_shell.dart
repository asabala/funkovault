import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/academy/atlas_academy_screen.dart';
import '../screens/home/atlas_home_screen.dart';
import '../screens/insights/atlas_insights_screen.dart';
import '../screens/scanner/scan_screen.dart';
import '../screens/settings/settings_screen.dart';
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

  static const int _scannerIndex = 2;

  @override
  Widget build(BuildContext context) {
    final AtlasNavigationController controller = context
        .watch<AtlasNavigationController>();

    final List<Widget> pages = <Widget>[
      const AtlasHomeScreen(),
      const CollectorVaultScreen(),

      // Only create ScanScreen while the Scan tab is active.
      //
      // This prevents MobileScanner from initializing the camera when
      // Atlas first launches and disposes the scanner when the user
      // leaves the Scan tab.
      if (controller.index == _scannerIndex)
        const ScanScreen(key: ValueKey<String>('atlas-active-scanner'))
      else
        const SizedBox.shrink(key: ValueKey<String>('atlas-inactive-scanner')),

      const AtlasInsightsScreen(),
      const AtlasAcademyScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: controller.index, children: pages),
      bottomNavigationBar: AtlasBottomNavigation(
        currentIndex: controller.index,
        onTap: controller.goTo,
      ),
    );
  }
}
