import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/engines/atlas_insight_engine.dart';
import '../../atlas/engines/atlas_recommendation_engine.dart';
import '../../atlas/services/atlas_activity_service.dart';
import '../../atlas/widgets/atlas_insight_card.dart';
import '../../models/funko_catalog_item.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/pop/labeled_dropdown.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class AddPopScreen extends StatefulWidget {
  const AddPopScreen({
    super.key,
    this.catalogItem,
  });

  final FunkoCatalogItem? catalogItem;

  @override
  State<AddPopScreen> createState() => _AddPopScreenState();
}

class _AddPopScreenState extends State<AddPopScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _categoryController = TextEditingController();
  final _seriesController = TextEditingController();
  final _valueController = TextEditingController();
  final _pricePaidController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  String _variant = 'Common';
  String _retailExclusive = 'None';
  String _eventSticker = 'None';
  String _limitedEdition = 'None';
  String _signature = 'Unsigned';

  final List<String> _variantOptions = const [
    'Common',
    'Chase',
    'Glow',
    'Flocked',
    'Blacklight',
    'Metallic',
    'Diamond',
    'Chrome',
    'Glitter',
    'Scented',
    'Art Series',
    'NFT Redemption',
    'Prototype',
    'Error Variant',
  ];

  final List<String> _retailOptions = const [
    'None',
    'Funko Shop',
    'Hot Topic',
    'BoxLunch',
    'Target',
    'Walmart',
    'Amazon',
    'GameStop',
    'Entertainment Earth',
    'PX',
    'Best Buy',
    'Walgreens',
    'Barnes & Noble',
    'FYE',
    'Books-A-Million',
    'Specialty Series',
    'Local Comic Shop',
  ];

  final List<String> _eventOptions = const [
    'None',
    'SDCC',
    'NYCC',
    'ECCC',
    'WonderCon',
    'C2E2',
    'Fundays',
    'Shared Exclusive',
  ];

  final List<String> _limitedOptions = const [
    'None',
    'LE 500',
    'LE 1000',
    'LE 1500',
    'LE 3000',
    'LE 5000',
    'LE 10000',
  ];

  final List<String> _signatureOptions = const [
    'Unsigned',
    'Signed',
    'Beckett Authenticated',
    'JSA Authenticated',
    'PSA Authenticated',
  ];

  String _formatCategory(String value) {
    if (value.isEmpty) {
      return '';
    }

    const upperCategories = {
      'dc': 'DC',
      'wwe': 'WWE',
      'nba': 'NBA',
      'nfl': 'NFL',
      'mlb': 'MLB',
      'ufc': 'UFC',
    };

    final lower = value.toLowerCase();

    if (upperCategories.containsKey(lower)) {
      return upperCategories[lower]!;
    }

    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : word[0].toUpperCase() + word.substring(1).toLowerCase(),
    )
        .join(' ');
  }

  @override
  void initState() {
    super.initState();

    final item = widget.catalogItem;

    if (item != null) {
      _nameController.text = item.title;

      if (item.series.isNotEmpty) {
        _seriesController.text = item.series.first;
        _categoryController.text = item.series.first;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _categoryController.dispose();
    _seriesController.dispose();
    _valueController.dispose();
    _pricePaidController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _savePop() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    final pop = Pop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      number: _numberController.text.trim(),
      category: _formatCategory(_categoryController.text.trim()),
      series: _seriesController.text.trim(),
      edition: _variant,
      variant: _variant,
      retailExclusive: _retailExclusive,
      eventSticker: _eventSticker,
      limitedEdition: _limitedEdition,
      signature: _signature,
      value: double.tryParse(_valueController.text) ?? 0,
      pricePaid: double.tryParse(_pricePaidController.text) ?? 0,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      itemCondition: '',
      boxCondition: '',
      imageUrl: widget.catalogItem?.imageName ?? '',
      owner: 'Shared',
      isWishlist: false,
      dateAdded: now,
      lastUpdated: now,
    );

    await context.read<AppState>().addPop(pop);

    AtlasActivityService.record(
      title: 'Pop Added',
      description: '${pop.name} #${pop.number} was added to the Vault.',
      type: 'pop_added',
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const insightEngine = AtlasInsightEngine();

    final collectorInsight = insightEngine.buildCollectorIdentityInsight(
      variant: _variant,
      retailExclusive: _retailExclusive,
      eventSticker: _eventSticker,
      limitedEdition: _limitedEdition,
      signature: _signature,
    );

    const recommendationEngine = AtlasRecommendationEngine();

    final collectorRecommendation =
    recommendationEngine.buildCollectorIdentityRecommendation(
      variant: _variant,
      retailExclusive: _retailExclusive,
      eventSticker: _eventSticker,
      limitedEdition: _limitedEdition,
      signature: _signature,
      value: double.tryParse(_valueController.text) ?? 0,
      pricePaid: double.tryParse(_pricePaidController.text) ?? 0,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Add Funko Pop'),
      ),
      body: Form(
        key: _formKey,
        child: VaultScrollView(
          children: [
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Pop',
                    style: AtlasTypography.headingLarge,
                  ),
                  const SizedBox(height: AtlasSpacing.sm),
                  Text(
                    'Add a new Pop to your current vault. Atlas will save the added date and updated date automatically.',
                    style: AtlasTypography.bodyMedium.copyWith(
                      color: AtlasColors.textSecondary,
                    ),
                  ),
                  if (widget.catalogItem != null) ...[
                    const SizedBox(height: AtlasSpacing.lg),
                    AtlasGlassPanel(
                      child: Row(
                        children: [
                          _AddPopImage(
                            imageUrl: widget.catalogItem?.imageName ?? '',
                          ),
                          const SizedBox(width: AtlasSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.catalogItem!.title,
                                  style: AtlasTypography.headingSmall,
                                ),
                                const SizedBox(height: AtlasSpacing.xs),
                                Text(
                                  'Catalog item selected',
                                  style: AtlasTypography.bodySmall.copyWith(
                                    color: AtlasColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AddSectionHeader(
                    title: 'Basic Information',
                    icon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasTextField(
                    controller: _nameController,
                    label: 'Pop Name',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasTextField(
                    controller: _numberController,
                    label: 'Pop Number',
                    icon: Icons.tag_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasTextField(
                    controller: _categoryController,
                    label: 'Category',
                    icon: Icons.category_outlined,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasTextField(
                    controller: _seriesController,
                    label: 'Series',
                    hintText: 'Pop! Marvel',
                    icon: Icons.collections_bookmark_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AddSectionHeader(
                    title: 'Collector Identity',
                    icon: Icons.verified_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasInsightCard(
                    title: collectorInsight.title,
                    message: collectorInsight.message,
                  ),
                  if (collectorRecommendation != null) ...[
                    const SizedBox(height: AtlasSpacing.md),
                    AtlasInsightCard(
                      title: collectorRecommendation.title,
                      message: collectorRecommendation.message,
                      icon: Icons.lightbulb_outline,
                    ),
                  ],
                  const SizedBox(height: AtlasSpacing.lg),
                  _AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Variant',
                      value: _variant,
                      options: _variantOptions,
                      onChanged: (value) {
                        setState(() {
                          _variant = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Retail Exclusive',
                      value: _retailExclusive,
                      options: _retailOptions,
                      onChanged: (value) {
                        setState(() {
                          _retailExclusive = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Event Sticker',
                      value: _eventSticker,
                      options: _eventOptions,
                      onChanged: (value) {
                        setState(() {
                          _eventSticker = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Limited Edition',
                      value: _limitedEdition,
                      options: _limitedOptions,
                      onChanged: (value) {
                        setState(() {
                          _limitedEdition = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Signature',
                      value: _signature,
                      options: _signatureOptions,
                      onChanged: (value) {
                        setState(() {
                          _signature = value;
                        });
                      },
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
                  const _AddSectionHeader(
                    title: 'Value',
                    icon: Icons.attach_money_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasTextField(
                    controller: _valueController,
                    label: 'Estimated Value (\$)',
                    icon: Icons.trending_up_rounded,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasTextField(
                    controller: _pricePaidController,
                    label: 'Price Paid (\$)',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AddSectionHeader(
                    title: 'Ownership',
                    icon: Icons.inventory_2_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasTextField(
                    controller: _quantityController,
                    label: 'Quantity',
                    icon: Icons.format_list_numbered_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasGlassPanel(
                    child: Text(
                      'Owner defaults to Shared. You can change the owner later from Edit Pop.',
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AtlasSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _savePop,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Pop'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPopImage extends StatelessWidget {
  const _AddPopImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final cleanImageUrl = imageUrl.trim();

    return Container(
      width: 76,
      height: 96,
      decoration: BoxDecoration(
        color: AtlasColors.textSecondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AtlasSpacing.md),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanImageUrl.isEmpty
          ? const Icon(
        Icons.inventory_2_rounded,
        size: 40,
      )
          : Image.network(
        cleanImageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image_rounded,
            size: 40,
          );
        },
      ),
    );
  }
}

class _AddSectionHeader extends StatelessWidget {
  const _AddSectionHeader({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AtlasColors.vaultGold,
        ),
        const SizedBox(width: AtlasSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: AtlasTypography.headingSmall,
          ),
        ),
      ],
    );
  }
}

class _AtlasTextField extends StatelessWidget {
  const _AtlasTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hintText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _AtlasDropdownPanel extends StatelessWidget {
  const _AtlasDropdownPanel({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: child,
    );
  }
}