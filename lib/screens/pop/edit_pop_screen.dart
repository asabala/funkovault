import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/engines/atlas_insight_engine.dart';
import '../../atlas/engines/atlas_recommendation_engine.dart';
import '../../atlas/services/atlas_activity_service.dart';
import '../../atlas/widgets/atlas_insight_card.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/pop/labeled_dropdown.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class EditPopScreen extends StatefulWidget {
  const EditPopScreen({
    super.key,
    required this.pop,
  });

  final Pop pop;

  @override
  State<EditPopScreen> createState() => _EditPopScreenState();
}

class _EditPopScreenState extends State<EditPopScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _categoryController;
  late TextEditingController _seriesController;
  late TextEditingController _valueController;
  late TextEditingController _pricePaidController;
  late TextEditingController _quantityController;

  late String _owner;
  late String _variant;
  late String _retailExclusive;
  late String _eventSticker;
  late String _limitedEdition;
  late String _signature;

  final List<String> _ownerOptions = const [
    'Arthur',
    'Natacia',
    'Amerika',
    'Nyssa',
    'Angelica',
    'Shared',
  ];

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

  String _safeOption(
      String value,
      List<String> options,
      String fallback,
      ) {
    return options.contains(value) ? value : fallback;
  }

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

    _nameController = TextEditingController(text: widget.pop.name);
    _numberController = TextEditingController(text: widget.pop.number);
    _categoryController = TextEditingController(text: widget.pop.category);
    _seriesController = TextEditingController(text: widget.pop.series);
    _valueController = TextEditingController(text: widget.pop.value.toString());
    _pricePaidController =
        TextEditingController(text: widget.pop.pricePaid.toString());
    _quantityController =
        TextEditingController(text: widget.pop.quantity.toString());

    _owner = _safeOption(
      widget.pop.owner,
      _ownerOptions,
      'Shared',
    );

    _variant = _safeOption(
      widget.pop.variant,
      _variantOptions,
      widget.pop.edition.isNotEmpty ? widget.pop.edition : 'Common',
    );

    if (!_variantOptions.contains(_variant)) {
      _variant = 'Common';
    }

    _retailExclusive = _safeOption(
      widget.pop.retailExclusive,
      _retailOptions,
      'None',
    );

    _eventSticker = _safeOption(
      widget.pop.eventSticker,
      _eventOptions,
      'None',
    );

    _limitedEdition = _safeOption(
      widget.pop.limitedEdition,
      _limitedOptions,
      'None',
    );

    _signature = _safeOption(
      widget.pop.signature,
      _signatureOptions,
      'Unsigned',
    );
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

  Future<void> _saveChanges() async {
    final updatedPop = Pop(
      id: widget.pop.id,
      name: _nameController.text.trim(),
      number: _numberController.text.trim(),
      category: _formatCategory(
        _categoryController.text.trim(),
      ),
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
      itemCondition: widget.pop.itemCondition,
      boxCondition: widget.pop.boxCondition,
      imageUrl: widget.pop.imageUrl,
      owner: _owner,
      isWishlist: widget.pop.isWishlist,
      dateAdded: widget.pop.dateAdded,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    await context.read<AppState>().updatePop(updatedPop);

    AtlasActivityService.record(
      title: 'Pop Updated',
      description: '${updatedPop.name} #${updatedPop.number} was updated.',
      type: 'pop_updated',
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, updatedPop);
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
        title: const Text('Edit Pop'),
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
                    'Edit Pop',
                    style: AtlasTypography.headingLarge,
                  ),
                  const SizedBox(height: AtlasSpacing.sm),
                  Text(
                    'Update the Pop details, collector identity, ownership, and value information.',
                    style: AtlasTypography.bodyMedium.copyWith(
                      color: AtlasColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.lg),
                  AtlasGlassPanel(
                    child: Row(
                      children: [
                        _EditPopImage(
                          imageUrl: widget.pop.imageUrl,
                        ),
                        const SizedBox(width: AtlasSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pop.name,
                                style: AtlasTypography.headingSmall,
                              ),
                              const SizedBox(height: AtlasSpacing.xs),
                              Text(
                                widget.pop.number.trim().isEmpty
                                    ? 'No number saved'
                                    : '#${widget.pop.number}',
                                style: AtlasTypography.bodySmall.copyWith(
                                  color: AtlasColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AtlasSpacing.xs),
                              Text(
                                widget.pop.collectorLabel,
                                style: AtlasTypography.bodySmall.copyWith(
                                  color: AtlasColors.vaultGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                  const _EditSectionHeader(
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
                  const _EditSectionHeader(
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
                  const _EditSectionHeader(
                    title: 'Ownership',
                    icon: Icons.inventory_2_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Owner',
                      value: _owner,
                      options: _ownerOptions,
                      onChanged: (value) {
                        setState(() {
                          _owner = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasTextField(
                    controller: _quantityController,
                    label: 'Quantity',
                    icon: Icons.format_list_numbered_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _EditSectionHeader(
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
            const SizedBox(height: AtlasSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditPopImage extends StatelessWidget {
  const _EditPopImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AtlasSpacing.md),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isEmpty
          ? const Icon(
        Icons.inventory_2_rounded,
        size: 40,
      )
          : Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.inventory_2_rounded,
            size: 40,
          );
        },
      ),
    );
  }
}

class _EditSectionHeader extends StatelessWidget {
  const _EditSectionHeader({
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
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
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