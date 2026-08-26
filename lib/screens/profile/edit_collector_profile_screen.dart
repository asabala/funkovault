import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/country_registry.dart';
import '../../models/collector_profile.dart';
import '../../models/country_option.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_icons.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_form_field.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/profile/country/country_dropdown.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class EditCollectorProfileScreen extends StatefulWidget {
  const EditCollectorProfileScreen({
    super.key,
  });

  @override
  State<EditCollectorProfileScreen> createState() {
    return _EditCollectorProfileScreenState();
  }
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

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final profile =
        context.read<AppState>().collectorProfile;

    _nameController = TextEditingController(
      text: profile.displayName,
    );

    _titleController = TextEditingController(
      text: profile.collectorTitle,
    );

    _mottoController = TextEditingController(
      text: profile.collectorMotto,
    );

    _bioController = TextEditingController(
      text: profile.bio,
    );

    _favoriteCategoryController =
        TextEditingController(
          text: profile.favoriteCategory,
        );

    _favoriteFranchiseController =
        TextEditingController(
          text: profile.favoriteFranchise,
        );

    _dreamGrailController =
        TextEditingController(
          text: profile.dreamGrail,
        );

    _collectorLevelController =
        TextEditingController(
          text: profile.collectorLevel,
        );

    _selectedCountry = CountryRegistry.findByCode(
      profile.countryCode,
    );

    _nameController.addListener(
      _refreshPreview,
    );

    _titleController.addListener(
      _refreshPreview,
    );

    _mottoController.addListener(
      _refreshPreview,
    );
  }

  void _refreshPreview() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(
      _refreshPreview,
    );

    _titleController.removeListener(
      _refreshPreview,
    );

    _mottoController.removeListener(
      _refreshPreview,
    );

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
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final appState =
      context.read<AppState>();

      final current =
          appState.collectorProfile;

      final updated = CollectorProfile(
        id: current.id,
        atlasId: current.atlasId,
        displayName:
        _nameController.text.trim(),
        collectorTitle:
        _titleController.text.trim(),
        collectorMotto:
        _mottoController.text.trim(),
        bio:
        _bioController.text.trim(),
        favoriteCategory:
        _favoriteCategoryController
            .text
            .trim(),
        favoriteFranchise:
        _favoriteFranchiseController
            .text
            .trim(),
        dreamGrail:
        _dreamGrailController
            .text
            .trim(),
        country: _selectedCountry.name,
        countryCode: _selectedCountry.code,
        countryFlag: _selectedCountry.flag,
        avatarUrl: current.avatarUrl,
        bannerUrl: current.bannerUrl,
        collectorLevel:
        _collectorLevelController
            .text
            .trim(),
        joinYear: current.joinYear,
        isPremium: current.isPremium,
      );

      await appState.updateCollectorProfile(
        updated,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Atlas could not save your collector profile. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      AtlasColors.background,
      appBar: AppBar(
        title: const Text(
          'Atlas Identity Studio',
        ),
      ),
      body: VaultScrollView(
        children: [
          const AtlasGlassCard(
            accentColor:
            AtlasColors.vaultGold,
            child: AtlasSectionHeader(
              title: 'Customize Your Vault',
              subtitle:
              'Shape how your collector identity appears across Atlas.',
              icon: AtlasIcons.atlas,
              accentColor:
              AtlasColors.vaultGold,
              titleStyle:
              AtlasTypography.headingLarge,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          _AtlasIdentityPreview(
            displayName:
            _nameController.text,
            collectorTitle:
            _titleController.text,
            collectorMotto:
            _mottoController.text,
            country:
            _selectedCountry.name,
            countryFlag:
            _selectedCountry.flag,
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          _StudioSection(
            title: 'Collector Identity',
            subtitle:
            'Set the public-facing identity Atlas uses throughout your vault.',
            icon:
            Icons.badge_outlined,
            children: [
              AtlasFormField(
                controller:
                _nameController,
                label: 'Collector Name',
                icon:
                Icons.person_outline,
                maxLength: 25,
                textCapitalization:
                TextCapitalization.words,
              ),
              AtlasFormField(
                controller:
                _titleController,
                label: 'Collector Title',
                icon:
                Icons.badge_outlined,
                maxLength: 30,
                textCapitalization:
                TextCapitalization.words,
              ),
              AtlasFormField(
                controller:
                _mottoController,
                label: 'Collector Motto',
                icon:
                Icons.format_quote,
                maxLength: 60,
                textCapitalization:
                TextCapitalization.sentences,
              ),
              AtlasFormField(
                controller:
                _collectorLevelController,
                label: 'Collector Level',
                icon: Icons
                    .military_tech_outlined,
                maxLength: 20,
                textCapitalization:
                TextCapitalization.words,
              ),
            ],
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          _StudioSection(
            title: 'Collector Story',
            subtitle:
            'Add the categories, franchises, and grails that define your collection.',
            icon:
            Icons.auto_stories_outlined,
            children: [
              AtlasFormField(
                controller:
                _favoriteCategoryController,
                label:
                'Favorite Category',
                icon:
                Icons.category_outlined,
                maxLength: 25,
                textCapitalization:
                TextCapitalization.words,
              ),
              AtlasFormField(
                controller:
                _favoriteFranchiseController,
                label:
                'Favorite Franchise',
                icon: Icons
                    .auto_awesome_outlined,
                maxLength: 35,
                textCapitalization:
                TextCapitalization.words,
              ),
              AtlasFormField(
                controller:
                _dreamGrailController,
                label: 'Dream Grail',
                icon:
                Icons.diamond_outlined,
                maxLength: 45,
                textCapitalization:
                TextCapitalization.words,
              ),
              AtlasFormField(
                controller:
                _bioController,
                label: 'Collector Bio',
                icon:
                Icons.notes_outlined,
                maxLength: 160,
                maxLines: 3,
                minLines: 3,
                textCapitalization:
                TextCapitalization.sentences,
              ),
            ],
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          _StudioSection(
            title: 'Collector Region',
            subtitle:
            'Set the country associated with your collector profile.',
            icon:
            Icons.public_rounded,
            children: [
              CountryDropdown(
                selectedCountry:
                _selectedCountry,
                onChanged: (country) {
                  setState(() {
                    _selectedCountry =
                        country;
                  });
                },
              ),
            ],
          ),

          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          const AtlasInfoBanner(
            icon:
            Icons.info_outline_rounded,
            title:
            'Collector Identity',
            message:
            'Profile changes update how your collector identity appears across Atlas. Premium status will eventually be managed by account subscription state rather than profile editing.',
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
              _isSaving
                  ? null
                  : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.save_rounded,
              ),
              label: Text(
                _isSaving
                    ? 'Saving Profile'
                    : 'Save Vault Profile',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioSection extends StatelessWidget {
  const _StudioSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          Column(
            children: [
              for (
              int i = 0;
              i < children.length;
              i++
              ) ...[
                children[i],
                if (i !=
                    children.length - 1)
                  const SizedBox(
                    height:
                    AtlasSpacing.md,
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AtlasIdentityPreview
    extends StatelessWidget {
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
      accentColor:
      AtlasColors.vaultGold,
      child: Column(
        children: [
          const Icon(
            AtlasIcons.atlas,
            color:
            AtlasColors.vaultGold,
            size: 40,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          Text(
            'ATLAS IDENTITY PREVIEW',
            style:
            AtlasTypography.label.copyWith(
              color:
              AtlasColors.vaultGold,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          Container(
            height: 78,
            width: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AtlasColors.vaultGold
                  .withValues(
                alpha: 0.16,
              ),
              border: Border.all(
                color:
                AtlasColors.vaultGold,
              ),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color:
              AtlasColors.vaultGold,
              size: 42,
            ),
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          Text(
            displayName.trim().isEmpty
                ? 'Collector Name'
                : displayName.trim(),
            style:
            AtlasTypography.headingLarge,
            textAlign:
            TextAlign.center,
          ),
          const SizedBox(
            height: AtlasSpacing.xs,
          ),
          Text(
            collectorTitle.trim().isEmpty
                ? 'Atlas Collector'
                : collectorTitle.trim(),
            style:
            AtlasTypography.bodyMedium
                .copyWith(
              color: AtlasColors
                  .textSecondary,
            ),
            textAlign:
            TextAlign.center,
          ),
          const SizedBox(
            height: AtlasSpacing.sm,
          ),
          Text(
            collectorMotto.trim().isEmpty
                ? 'Collector. Curator. Explorer.'
                : collectorMotto.trim(),
            style:
            AtlasTypography.bodySmall
                .copyWith(
              color:
              AtlasColors.vaultGold,
            ),
            textAlign:
            TextAlign.center,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          Text(
            '$countryFlag $country',
            style:
            AtlasTypography.bodyMedium,
            textAlign:
            TextAlign.center,
          ),
        ],
      ),
    );
  }
}