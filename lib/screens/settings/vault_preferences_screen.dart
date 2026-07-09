import 'package:flutter/material.dart';

import '../../services/hive_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';

class VaultPreferencesScreen extends StatefulWidget {
  const VaultPreferencesScreen({super.key});

  @override
  State<VaultPreferencesScreen> createState() => _VaultPreferencesScreenState();
}

class _VaultPreferencesScreenState extends State<VaultPreferencesScreen> {
  static const String _preferencesStorageKey = 'entire_vault_preferences';

  Map<String, dynamic> _preferences = const {
    'filterMode': 'all',
    'sortMode': 'nameAz',
    'showImages': false,
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final data = HiveService.loadData(
      _preferencesStorageKey,
    );

    if (data == null) {
      return;
    }

    setState(() {
      _preferences = {
        'filterMode': data['filterMode'] ?? 'all',
        'sortMode': data['sortMode'] ?? 'nameAz',
        'showImages': data['showImages'] == true,
      };
    });
  }

  Future<void> _resetEntireVaultPreferences() async {
    const defaultPreferences = {
      'filterMode': 'all',
      'sortMode': 'nameAz',
      'showImages': false,
    };

    await HiveService.saveData(
      _preferencesStorageKey,
      defaultPreferences,
    );

    setState(() {
      _preferences = defaultPreferences;
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entire Vault preferences reset.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterLabel = _filterLabel(
      _preferences['filterMode'],
    );

    final sortLabel = _sortLabel(
      _preferences['sortMode'],
    );

    final showImages = _preferences['showImages'] == true;
    final imageLabel = showImages ? 'On' : 'Off';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault Preferences'),
      ),
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
                    Text(
                      'Vault Preferences',
                      style: AtlasTypography.headingLarge,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Manage saved Vault behavior like filters, sorting, and image display.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entire Vault Saved View',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Entire Vault remembers filter, sort, and image settings. Search text and load count are not saved.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    _PreferenceRow(
                      icon: Icons.filter_list_rounded,
                      label: 'Saved Filter',
                      value: filterLabel,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _PreferenceRow(
                      icon: Icons.sort_rounded,
                      label: 'Saved Sort',
                      value: sortLabel,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    _PreferenceRow(
                      icon: showImages
                          ? Icons.image_rounded
                          : Icons.image_not_supported_outlined,
                      label: 'Images',
                      value: imageLabel,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Preferences',
                      style: AtlasTypography.headingSmall,
                    ),
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Reset Entire Vault back to All, Name A-Z, and Images Off.',
                      style: AtlasTypography.bodyMedium.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _resetEntireVaultPreferences,
                        icon: const Icon(
                          Icons.restart_alt_rounded,
                        ),
                        label: const Text(
                          'Reset Entire Vault Preferences',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassPanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AtlasColors.vaultGold,
                    ),
                    const SizedBox(width: AtlasSpacing.md),
                    Expanded(
                      child: Text(
                        'Future saved views, premium layouts, and default room filters can live here without cluttering the Vault Dashboard.',
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _filterLabel(dynamic value) {
    switch (value) {
      case 'owned':
        return 'Owned';
      case 'wishlist':
        return 'Wishlist';
      case 'needsValue':
        return 'Needs Value';
      case 'hasValue':
        return 'Has Value';
      case 'exclusives':
        return 'Exclusives';
      case 'signed':
        return 'Signed';
      case 'limited':
        return 'Limited';
      case 'variants':
        return 'Variants';
      case 'stickers':
        return 'Stickers';
      case 'all':
      default:
        return 'All';
    }
  }

  String _sortLabel(dynamic value) {
    switch (value) {
      case 'highestValue':
        return 'Highest Value';
      case 'needsValue':
        return 'Needs Value';
      case 'newestAdded':
        return 'Newest Added';
      case 'recentlyUpdated':
        return 'Recently Updated';
      case 'nameAz':
      default:
        return 'Name A-Z';
    }
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: Row(
        children: [
          Icon(
            icon,
            color: AtlasColors.vaultGold,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AtlasTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AtlasSpacing.sm),
          Text(
            value,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.vaultGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}