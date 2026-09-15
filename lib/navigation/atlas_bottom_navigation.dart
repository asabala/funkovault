import 'package:flutter/material.dart';

import '../theme/atlas_colors.dart';
import '../theme/atlas_icons.dart';

class AtlasBottomNavigation extends StatelessWidget {
  const AtlasBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: AtlasColors.surface,
      indicatorColor: AtlasColors.intelligenceBlue.withValues(alpha: 0.18),
      destinations: const [
        NavigationDestination(
          icon: Icon(AtlasIcons.atlas),
          selectedIcon: Icon(AtlasIcons.intelligence),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(AtlasIcons.collection),
          label: 'Vault',
        ),
        NavigationDestination(
          icon: Icon(Icons.qr_code_scanner_outlined),
          selectedIcon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        NavigationDestination(icon: Icon(AtlasIcons.trend), label: 'Insights'),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Academy',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
