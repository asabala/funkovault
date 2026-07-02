import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/atlas_home_screen.dart';
import '../screens/atlas_insights_screen.dart';
import '../screens/auth/login_screen.dart';
import '../security/auth_provider.dart';
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
      const _SettingsPage(),
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

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthProvider>().signOut();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AtlasColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            Icons.settings,
            size: 64,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(height: 16),
          Text(
            'Atlas Settings',
            style: AtlasTypography.headingLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Account, preferences, and app settings will live here.',
            style: AtlasTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: Icon(
                authProvider.isLoggedIn
                    ? Icons.verified_user_outlined
                    : Icons.person_outline,
              ),
              title: Text(
                authProvider.isLoggedIn
                    ? 'Signed in to Atlas'
                    : 'Guest Mode',
              ),
              subtitle: Text(
                authProvider.isPremium
                    ? 'Premium collector account'
                    : 'Basic collector account',
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            label: Text(
              authProvider.isLoggedIn ? 'Sign Out' : 'Return to Login',
            ),
          ),
        ],
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