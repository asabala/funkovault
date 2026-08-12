import 'package:flutter/material.dart';

import '../../services/hive_service.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_action_row.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';

class VaultPreferencesScreen extends StatefulWidget {
  const VaultPreferencesScreen({
    super.key,
  });

  @override
  State<VaultPreferencesScreen> createState() {
    return _VaultPreferencesScreenState();
  }
}

class _VaultPreferencesScreenState
    extends State<VaultPreferencesScreen> {
  static const String _preferencesStorageKey =
      'entire_vault_preferences';

  static const Map<String, dynamic> _defaultPreferences = {
    'filterMode': 'all',
    'sortMode': 'nameAz',
    'showImages': false,
  };

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
    try {
      await HiveService.saveData(
        _preferencesStorageKey,
        _defaultPreferences,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _preferences = Map<String, dynamic>.from(
          _defaultPreferences,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Entire Vault preferences reset.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Atlas could not reset Vault preferences. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String filterLabel = _filterLabel(
      _preferences['filterMode'],
    );

    final String sortLabel = _sortLabel(
      _preferences['sortMode'],
    );

    final bool showImages =
        _preferences['showImages'] == true;

    final String imageLabel =
    showImages ? 'On' : 'Off';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vault Preferences',
        ),
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
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              const AtlasGlassCard(
                accentColor: AtlasColors.vaultGold,
                child: AtlasSectionHeader(
                  title: 'Vault Preferences',
                  subtitle:
                  'Manage saved Vault behavior like filters, sorting, and image display.',
                  icon: Icons.tune_rounded,
                  accentColor:
                  AtlasColors.vaultGold,
                ),
              ),
              const SizedBox(
                height: AtlasSpacing.lg,
              ),
              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const AtlasSectionHeader(
                      title:
                      'Entire Vault Saved View',
                      subtitle:
                      'Entire Vault remembers filter, sort, and image settings. Search text and load count are not saved.',
                      icon: Icons
                          .bookmark_added_outlined,
                    ),
                    const SizedBox(
                      height: AtlasSpacing.lg,
                    ),
                    AtlasActionRow(
                      title: 'Saved Filter',
                      description:
                      'Current default filter for Entire Vault.',
                      icon:
                      Icons.filter_list_rounded,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: filterLabel,
                        accentColor:
                        AtlasColors.vaultGold,
                        size: AtlasStatusChipSize
                            .compact,
                      ),
                    ),
                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),
                    AtlasActionRow(
                      title: 'Saved Sort',
                      description:
                      'Current default sorting for Entire Vault.',
                      icon: Icons.sort_rounded,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: sortLabel,
                        accentColor:
                        AtlasColors.vaultGold,
                        size: AtlasStatusChipSize
                            .compact,
                      ),
                    ),
                    const SizedBox(
                      height: AtlasSpacing.sm,
                    ),
                    AtlasActionRow(
                      title: 'Images',
                      description: showImages
                          ? 'Images are enabled by default in Entire Vault.'
                          : 'Images are disabled by default for faster scrolling.',
                      icon: showImages
                          ? Icons.image_rounded
                          : Icons
                          .image_not_supported_outlined,
                      showChevron: false,
                      compact: true,
                      badge: AtlasStatusChip(
                        label: imageLabel,
                        accentColor:
                        AtlasColors.vaultGold,
                        size: AtlasStatusChipSize
                            .compact,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: AtlasSpacing.lg,
              ),
              AtlasGlassCard(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const AtlasSectionHeader(
                      title: 'Reset Preferences',
                      subtitle:
                      'Reset Entire Vault back to All, Name A-Z, and Images Off.',
                      icon:
                      Icons.restart_alt_rounded,
                    ),
                    const SizedBox(
                      height: AtlasSpacing.lg,
                    ),
                    AtlasActionRow(
                      title:
                      'Reset Entire Vault Preferences',
                      description:
                      'Restore the default filter, sort order, and image visibility.',
                      icon:
                      Icons.restart_alt_rounded,
                      accentColor:
                      AtlasColors.warning,
                      onTap:
                      _resetEntireVaultPreferences,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: AtlasSpacing.lg,
              ),
              const AtlasInfoBanner(
                icon: Icons.info_outline_rounded,
                title: 'Future Preferences',
                message:
                'Future saved views, Premium layouts, and default room filters can live here without cluttering the Vault Dashboard.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _filterLabel(
      dynamic value,
      ) {
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

      case 'duplicates':
        return 'Duplicates';

      case 'all':
      default:
        return 'All';
    }
  }

  String _sortLabel(
      dynamic value,
      ) {
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