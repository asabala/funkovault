import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/collector_profile.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/vault_scroll_view.dart';
import '../../data/country_registry.dart';
import '../../models/country_option.dart';
import '../../widgets/profile/country/country_dropdown.dart';

class EditCollectorProfileScreen extends StatefulWidget {
  const EditCollectorProfileScreen({super.key});

  @override
  State<EditCollectorProfileScreen> createState() =>
      _EditCollectorProfileScreenState();
}

class _EditCollectorProfileScreenState
    extends State<EditCollectorProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _mottoController;
  late final TextEditingController _bioController;
  late final TextEditingController _favoriteCategoryController;
  late final TextEditingController _favoriteFranchiseController;
  late final TextEditingController _dreamGrailController;
  late final TextEditingController _collectorLevelController;
  late CountryOption _selectedCountry;

  late bool _isPremium;

  @override
  void initState() {
    super.initState();

    final profile = context.read<AppState>().collectorProfile;

    _nameController = TextEditingController(text: profile.displayName);
    _titleController = TextEditingController(text: profile.collectorTitle);
    _mottoController = TextEditingController(text: profile.collectorMotto);
    _bioController = TextEditingController(text: profile.bio);
    _favoriteCategoryController =
        TextEditingController(text: profile.favoriteCategory);
    _favoriteFranchiseController =
        TextEditingController(text: profile.favoriteFranchise);
    _dreamGrailController = TextEditingController(text: profile.dreamGrail);
    _selectedCountry = CountryRegistry.findByCode(profile.countryCode);
    _collectorLevelController =
        TextEditingController(text: profile.collectorLevel);

    _isPremium = profile.isPremium;

    void refresh() => setState(() {});

    _nameController.addListener(refresh);
    _titleController.addListener(refresh);
    _mottoController.addListener(refresh);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _mottoController.dispose();
    _bioController.dispose();
    _favoriteCategoryController.dispose();
    _favoriteFranchiseController.dispose();
    _dreamGrailController.dispose();
    _collectorLevelController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    final appState = context.read<AppState>();
    final current = appState.collectorProfile;

    final updated = CollectorProfile(
      id: current.id,
      atlasId: current.atlasId,
      displayName: _nameController.text.trim(),
      collectorTitle: _titleController.text.trim(),
      collectorMotto: _mottoController.text.trim(),
      bio: _bioController.text.trim(),
      favoriteCategory: _favoriteCategoryController.text.trim(),
      favoriteFranchise: _favoriteFranchiseController.text.trim(),
      dreamGrail: _dreamGrailController.text.trim(),
      country: _selectedCountry.name,
      countryCode: _selectedCountry.code,
      countryFlag: _selectedCountry.flag,
      avatarUrl: current.avatarUrl,
      bannerUrl: current.bannerUrl,
      collectorLevel: _collectorLevelController.text.trim(),
      joinYear: current.joinYear,
      isPremium: _isPremium,
    );

    await appState.updateCollectorProfile(updated);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtlasColors.background,
      appBar: AppBar(
        title: const Text('Atlas Identity Studio'),
      ),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  AtlasIcons.atlas,
                  color: AtlasColors.vaultGold,
                  size: 42,
                ),
                const SizedBox(height: AtlasSpacing.md),
                Text(
                  'Customize Your Vault',
                  style: AtlasTypography.headingLarge,
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Text(
                  'Shape how your collector identity appears across Atlas.',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),

          _AtlasIdentityPreview(
            displayName: _nameController.text,
            collectorTitle: _titleController.text,
            collectorMotto: _mottoController.text,
            country: _selectedCountry.name,
            countryFlag: _selectedCountry.flag,
          ),

          const SizedBox(height: AtlasSpacing.lg),

          _StudioSection(
            title: 'Collector Identity',
            children: [
              _StudioTextField(
                controller: _nameController,
                label: 'Collector Name',
                icon: Icons.person_outline,
                maxLength: 25,
              ),
              _StudioTextField(
                controller: _titleController,
                label: 'Collector Title',
                icon: Icons.badge_outlined,
                maxLength: 30,
              ),
              _StudioTextField(
                controller: _mottoController,
                label: 'Collector Motto',
                icon: Icons.format_quote,
                maxLength: 60,
              ),
              _StudioTextField(
                controller: _collectorLevelController,
                label: 'Collector Level',
                icon: Icons.military_tech_outlined,
                maxLength: 20,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _StudioSection(
            title: 'Collector Story',
            children: [
              _StudioTextField(
                controller: _favoriteCategoryController,
                label: 'Favorite Category',
                icon: Icons.category_outlined,
                maxLength: 25,
              ),
              _StudioTextField(
                controller: _favoriteFranchiseController,
                label: 'Favorite Franchise',
                icon: Icons.auto_awesome_outlined,
                maxLength: 35,
              ),
              _StudioTextField(
                controller: _dreamGrailController,
                label: 'Dream Grail',
                icon: Icons.diamond_outlined,
                maxLength: 45,
              ),
              _StudioTextField(
                controller: _bioController,
                label: 'Collector Bio',
                icon: Icons.notes_outlined,
                maxLength: 160,
                maxLines: 3,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.lg),
          _StudioSection(
            title: 'Collector Region',
            children: [
              CountryDropdown(
                selectedCountry: _selectedCountry,
                onChanged: (country) {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.lg),
          AtlasGlassCard(
            child: SwitchListTile(
              value: _isPremium,
              onChanged: (value) {
                setState(() {
                  _isPremium = value;
                });
              },
              title: const Text('Premium Member'),
              subtitle: const Text('Temporary test toggle for Atlas Premium.'),
              secondary: const Icon(
                Icons.workspace_premium,
                color: AtlasColors.vaultGold,
              ),
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          FilledButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save),
            label: const Text('Save Vault Profile'),
          ),
        ],
      ),
    );
  }
}

class _StudioTextField extends StatelessWidget {
  const _StudioTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.maxLength,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLength;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
class _StudioSection extends StatelessWidget {
  const _StudioSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const SizedBox(height: AtlasSpacing.md),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
class _AtlasIdentityPreview extends StatelessWidget {
  const _AtlasIdentityPreview({
    required this.displayName,
    required this.collectorTitle,
    required this.collectorMotto,
    required this.country,
    required this.countryFlag,
  });

  final String displayName;
  final String collectorTitle;
  final String collectorMotto;
  final String country;
  final String countryFlag;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        children: [
          const Icon(
            AtlasIcons.atlas,
            color: AtlasColors.vaultGold,
            size: 40,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            'ATLAS IDENTITY PREVIEW',
            style: AtlasTypography.label.copyWith(
              color: AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Container(
            height: 78,
            width: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AtlasColors.vaultGold.withValues(alpha: 0.16),
              border: Border.all(
                color: AtlasColors.vaultGold,
              ),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AtlasColors.vaultGold,
              size: 42,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            displayName.isEmpty ? 'Collector Name' : displayName,
            style: AtlasTypography.headingLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            collectorTitle.isEmpty ? 'Atlas Collector' : collectorTitle,
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            collectorMotto.isEmpty
                ? 'Collector. Curator. Explorer.'
                : collectorMotto,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.vaultGold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            '$countryFlag $country',
            style: AtlasTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}