import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/engines/intelligence/atlas_insight_engine.dart';
import '../../atlas/engines/intelligence/atlas_recommendation_engine.dart';
import '../../models/activity.dart';
import '../../atlas/widgets/atlas_insight_card.dart';
import '../../constants/collector_identity_options.dart';
import '../../models/pop.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/components/atlas_dropdown_panel.dart';
import '../../widgets/atlas/components/atlas_form_field.dart';
import '../../widgets/atlas/components/atlas_product_image.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/pop/labeled_dropdown.dart';
import '../../widgets/pop/pop_form.dart';
import '../../widgets/vault/vault_scroll_view.dart';

enum EditPopInitialSection { none, collectorIdentity, condition, value }

class EditPopScreen extends StatefulWidget {
  const EditPopScreen({
    super.key,
    required this.pop,
    this.collectionName,
    this.initialSection = EditPopInitialSection.none,
    this.focusValueField = false,
  });

  final Pop pop;
  final String? collectionName;

  /// Opens Edit Pop at a specific section.
  final EditPopInitialSection initialSection;

  /// Preserved for existing callers that specifically want the
  /// Estimated Value field selected and focused.
  final bool focusValueField;

  @override
  State<EditPopScreen> createState() => _EditPopScreenState();
}

class _EditPopScreenState extends State<EditPopScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _collectorIdentitySectionKey = GlobalKey();
  final GlobalKey _conditionSectionKey = GlobalKey();
  final GlobalKey _valueSectionKey = GlobalKey();

  final FocusNode _itemConditionFocusNode = FocusNode();
  final FocusNode _valueFocusNode = FocusNode();

  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _categoryController;
  late TextEditingController _seriesController;
  late TextEditingController _valueController;
  late TextEditingController _pricePaidController;
  late TextEditingController _quantityController;
  late TextEditingController _itemConditionController;
  late TextEditingController _boxConditionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _customVariantController;
  late TextEditingController _customRetailExclusiveController;
  late TextEditingController _customEventStickerController;
  late TextEditingController _customLimitedEditionController;
  late TextEditingController _customSignatureController;

  late String _owner;
  late String _variant;
  late String _retailExclusive;
  late String _eventSticker;
  late String _limitedEdition;
  late String _signature;

  static const List<String> _defaultOwnerOptions = [
    'Arthur',
    'Natacia',
    'Amerika',
    'Nyssa',
    'Angelica',
    'Shared',
  ];

  late List<String> _ownerOptions;

  String _safeOption(String value, List<String> options, String fallback) {
    return options.contains(value) ? value : fallback;
  }

  bool _isCustomValue(String value, List<String> options) {
    final cleaned = value.trim();

    return cleaned.isNotEmpty && !options.contains(cleaned);
  }

  String _resolvedIdentityValue({
    required String selectedValue,
    required TextEditingController customController,
    required String fallback,
  }) {
    if (selectedValue != 'Other') {
      return selectedValue;
    }

    final customValue = customController.text.trim();

    return customValue.isEmpty ? fallback : customValue;
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
    _pricePaidController = TextEditingController(
      text: widget.pop.pricePaid.toString(),
    );
    _quantityController = TextEditingController(
      text: widget.pop.quantity.toString(),
    );
    _itemConditionController = TextEditingController(
      text: widget.pop.itemCondition,
    );
    _boxConditionController = TextEditingController(
      text: widget.pop.boxCondition,
    );
    _imageUrlController = TextEditingController(text: widget.pop.imageUrl);

    _owner = widget.pop.owner.trim().isEmpty
        ? 'Shared'
        : widget.pop.owner.trim();
    _ownerOptions = <String>[
      ..._defaultOwnerOptions,
      if (!_defaultOwnerOptions.contains(_owner)) _owner,
    ];

    final savedVariant = widget.pop.variant.trim().isNotEmpty
        ? widget.pop.variant.trim()
        : widget.pop.edition.trim();

    _customVariantController = TextEditingController(
      text: _isCustomValue(savedVariant, CollectorIdentityOptions.variants)
          ? savedVariant
          : '',
    );

    _variant = _isCustomValue(savedVariant, CollectorIdentityOptions.variants)
        ? 'Other'
        : _safeOption(
            savedVariant,
            CollectorIdentityOptions.variants,
            'Common',
          );

    _customRetailExclusiveController = TextEditingController(
      text:
          _isCustomValue(
            widget.pop.retailExclusive,
            CollectorIdentityOptions.retailExclusives,
          )
          ? widget.pop.retailExclusive
          : '',
    );

    _retailExclusive =
        _isCustomValue(
          widget.pop.retailExclusive,
          CollectorIdentityOptions.retailExclusives,
        )
        ? 'Other'
        : _safeOption(
            widget.pop.retailExclusive,
            CollectorIdentityOptions.retailExclusives,
            'None',
          );

    _customEventStickerController = TextEditingController(
      text:
          _isCustomValue(
            widget.pop.eventSticker,
            CollectorIdentityOptions.eventStickers,
          )
          ? widget.pop.eventSticker
          : '',
    );

    _eventSticker =
        _isCustomValue(
          widget.pop.eventSticker,
          CollectorIdentityOptions.eventStickers,
        )
        ? 'Other'
        : _safeOption(
            widget.pop.eventSticker,
            CollectorIdentityOptions.eventStickers,
            'None',
          );

    _customLimitedEditionController = TextEditingController(
      text:
          _isCustomValue(
            widget.pop.limitedEdition,
            CollectorIdentityOptions.limitedEditions,
          )
          ? widget.pop.limitedEdition
          : '',
    );

    _limitedEdition =
        _isCustomValue(
          widget.pop.limitedEdition,
          CollectorIdentityOptions.limitedEditions,
        )
        ? 'Other'
        : _safeOption(
            widget.pop.limitedEdition,
            CollectorIdentityOptions.limitedEditions,
            'None',
          );

    _customSignatureController = TextEditingController(
      text:
          _isCustomValue(
            widget.pop.signature,
            CollectorIdentityOptions.signatures,
          )
          ? widget.pop.signature
          : '',
    );

    _signature =
        _isCustomValue(
          widget.pop.signature,
          CollectorIdentityOptions.signatures,
        )
        ? 'Other'
        : _safeOption(
            widget.pop.signature,
            CollectorIdentityOptions.signatures,
            'Unsigned',
          );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focusValueField) {
        _focusValueSection();
        return;
      }

      _focusInitialSection();
    });
  }

  Future<void> _focusInitialSection() async {
    switch (widget.initialSection) {
      case EditPopInitialSection.none:
        return;

      case EditPopInitialSection.collectorIdentity:
        await _scrollToSection(_collectorIdentitySectionKey);
        return;

      case EditPopInitialSection.condition:
        await _scrollToSection(_conditionSectionKey);

        if (!mounted) {
          return;
        }

        _itemConditionFocusNode.requestFocus();
        return;

      case EditPopInitialSection.value:
        await _focusValueSection();
        return;
    }
  }

  Future<void> _scrollToSection(
    GlobalKey sectionKey, {
    double alignment = 0.12,
  }) async {
    if (!mounted) {
      return;
    }

    final BuildContext? sectionContext = sectionKey.currentContext;

    if (sectionContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      alignment: alignment,
    );
  }

  Future<void> _focusValueSection() async {
    await _scrollToSection(_valueSectionKey, alignment: 0.15);

    if (!mounted) {
      return;
    }

    _valueFocusNode.requestFocus();

    _valueController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _valueController.text.length,
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
    _itemConditionController.dispose();
    _boxConditionController.dispose();
    _imageUrlController.dispose();
    _scrollController.dispose();
    _itemConditionFocusNode.dispose();
    _valueFocusNode.dispose();
    _customVariantController.dispose();
    _customRetailExclusiveController.dispose();
    _customEventStickerController.dispose();
    _customLimitedEditionController.dispose();
    _customSignatureController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final resolvedVariant = _resolvedIdentityValue(
      selectedValue: _variant,
      customController: _customVariantController,
      fallback: 'Common',
    );

    final resolvedRetailExclusive = _resolvedIdentityValue(
      selectedValue: _retailExclusive,
      customController: _customRetailExclusiveController,
      fallback: 'None',
    );

    final resolvedEventSticker = _resolvedIdentityValue(
      selectedValue: _eventSticker,
      customController: _customEventStickerController,
      fallback: 'None',
    );

    final resolvedLimitedEdition = _resolvedIdentityValue(
      selectedValue: _limitedEdition,
      customController: _customLimitedEditionController,
      fallback: 'None',
    );

    final resolvedSignature = _resolvedIdentityValue(
      selectedValue: _signature,
      customController: _customSignatureController,
      fallback: 'Unsigned',
    );

    final updatedPop = widget.pop.copyWith(
      name: _nameController.text.trim(),
      number: _numberController.text.trim(),
      category: _formatCategory(_categoryController.text.trim()),
      series: _seriesController.text.trim(),
      variant: resolvedVariant,
      retailExclusive: resolvedRetailExclusive,
      eventSticker: resolvedEventSticker,
      limitedEdition: resolvedLimitedEdition,
      signature: resolvedSignature,
      value: PopFormValues.parseOptionalMoney(_valueController.text),
      pricePaid: PopFormValues.parseOptionalMoney(_pricePaidController.text),
      quantity: PopFormValues.parseQuantity(_quantityController.text),
      itemCondition: _itemConditionController.text.trim(),
      boxCondition: _boxConditionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      owner: _owner,
    );

    final appState = context.read<AppState>();
    final valueChanged = updatedPop.value != widget.pop.value;

    final persistedPop = await appState.updatePop(
      updatedPop,
      collectionName: widget.collectionName,
      existingRecordKey: widget.pop.collectionRecordKey,
    );

    if (persistedPop == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This Pop could not be found. No changes were saved.',
            ),
          ),
        );
      }

      return;
    }

    await appState.addActivity(
      Activity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        popId: persistedPop.id,
        action: valueChanged ? 'value_updated' : 'pop_updated',
        popName: persistedPop.name,
        popNumber: persistedPop.number,
        owner: persistedPop.owner,
        actor: persistedPop.owner,
        details: valueChanged
            ? _valueUpdateDetails(
                pop: persistedPop,
                previousValue: widget.pop.value,
              )
            : persistedPop.number.trim().isEmpty
            ? '${persistedPop.name} was updated'
            : '${persistedPop.name} #${persistedPop.number} was updated',
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, persistedPop);
  }

  String _valueUpdateDetails({
    required Pop pop,
    required double previousValue,
  }) {
    final previousLabel = previousValue <= 0
        ? 'not entered'
        : '\$${previousValue.toStringAsFixed(2)}';

    final updatedLabel = pop.value <= 0
        ? 'not entered'
        : '\$${pop.value.toStringAsFixed(2)}';

    return '${pop.name} value changed from $previousLabel to $updatedLabel';
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

    final collectorRecommendation = recommendationEngine
        .buildCollectorIdentityRecommendation(
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
      appBar: AppBar(title: const Text('Edit Pop')),
      body: Form(
        key: _formKey,
        child: VaultScrollView(
          controller: _scrollController,
          children: [
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Pop', style: AtlasTypography.headingLarge),
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
                        AtlasProductImage(
                          imageUrl: _imageUrlController.text,
                          width: 76,
                          height: 96,
                          borderRadius: AtlasSpacing.md,
                          showBorder: true,
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
                  const AtlasSectionHeader(
                    title: 'Basic Information',
                    subtitle: 'Update the core identity of this collectible.',
                    icon: Icons.info_outline_rounded,
                    accentColor: AtlasColors.vaultGold,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _nameController,
                    label: 'Pop Name',
                    icon: Icons.badge_outlined,
                    validator: PopFormValues.validateName,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _numberController,
                    label: 'Pop Number',
                    icon: Icons.tag_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _categoryController,
                    label: 'Category',
                    icon: Icons.category_outlined,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _seriesController,
                    label: 'Series',
                    icon: Icons.collections_bookmark_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              key: _collectorIdentitySectionKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AtlasSectionHeader(
                    title: 'Collector Identity',
                    subtitle:
                        'Update variants, exclusives, stickers, limited editions, and signatures.',
                    icon: Icons.verified_rounded,
                    accentColor: AtlasColors.vaultGold,
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
                  AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Variant',
                      value: _variant,
                      options: CollectorIdentityOptions.variants,
                      onChanged: (value) {
                        setState(() {
                          _variant = value;
                        });
                      },
                    ),
                  ),
                  if (_variant == 'Other') ...[
                    const SizedBox(height: AtlasSpacing.md),
                    AtlasFormField(
                      controller: _customVariantController,
                      label: 'Custom Variant',
                      icon: Icons.edit_note_rounded,
                    ),
                  ],
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Retail Exclusive',
                      value: _retailExclusive,
                      options: CollectorIdentityOptions.retailExclusives,
                      onChanged: (value) {
                        setState(() {
                          _retailExclusive = value;
                        });
                      },
                    ),
                  ),
                  if (_retailExclusive == 'Other') ...[
                    const SizedBox(height: AtlasSpacing.md),
                    AtlasFormField(
                      controller: _customRetailExclusiveController,
                      label: 'Custom Retail Exclusive',
                      icon: Icons.storefront_outlined,
                    ),
                  ],
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Event Sticker',
                      value: _eventSticker,
                      options: CollectorIdentityOptions.eventStickers,
                      onChanged: (value) {
                        setState(() {
                          _eventSticker = value;
                        });
                      },
                    ),
                  ),
                  if (_eventSticker == 'Other') ...[
                    const SizedBox(height: AtlasSpacing.md),
                    AtlasFormField(
                      controller: _customEventStickerController,
                      label: 'Custom Event Sticker',
                      icon: Icons.local_activity_outlined,
                    ),
                  ],
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Limited Edition',
                      value: _limitedEdition,
                      options: CollectorIdentityOptions.limitedEditions,
                      onChanged: (value) {
                        setState(() {
                          _limitedEdition = value;
                        });
                      },
                    ),
                  ),
                  if (_limitedEdition == 'Other') ...[
                    const SizedBox(height: AtlasSpacing.md),
                    AtlasFormField(
                      controller: _customLimitedEditionController,
                      label: 'Custom Limited Edition',
                      icon: Icons.numbers_rounded,
                    ),
                  ],
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasDropdownPanel(
                    child: LabeledDropdown(
                      label: 'Signature',
                      value: _signature,
                      options: CollectorIdentityOptions.signatures,
                      onChanged: (value) {
                        setState(() {
                          _signature = value;
                        });
                      },
                    ),
                  ),
                  if (_signature == 'Other') ...[
                    const SizedBox(height: AtlasSpacing.md),
                    AtlasFormField(
                      controller: _customSignatureController,
                      label: 'Custom Signature Details',
                      icon: Icons.draw_outlined,
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
                  const AtlasSectionHeader(
                    title: 'Ownership',
                    subtitle: 'Update the owner and physical copy count.',
                    icon: Icons.inventory_2_rounded,
                    accentColor: AtlasColors.vaultGold,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasDropdownPanel(
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
                  AtlasFormField(
                    controller: _quantityController,
                    label: 'Quantity',
                    icon: Icons.format_list_numbered_rounded,
                    keyboardType: TextInputType.number,
                    validator: PopFormValues.validateQuantity,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              key: _conditionSectionKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AtlasSectionHeader(
                    title: 'Condition & Image',
                    subtitle: 'Record the collectible, box, and display image.',
                    icon: Icons.photo_camera_back_outlined,
                    accentColor: AtlasColors.vaultGold,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _itemConditionController,
                    focusNode: _itemConditionFocusNode,
                    label: 'Item Condition',
                    icon: Icons.auto_awesome_outlined,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _boxConditionController,
                    label: 'Box Condition',
                    icon: Icons.inventory_2_outlined,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _imageUrlController,
                    label: 'Image URL',
                    icon: Icons.link_rounded,
                    keyboardType: TextInputType.url,
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              key: _valueSectionKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AtlasSectionHeader(
                    title: 'Value',
                    subtitle:
                        'Update estimated market value and what you paid.',
                    icon: Icons.attach_money_rounded,
                    accentColor: AtlasColors.vaultGold,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _valueController,
                    focusNode: _valueFocusNode,
                    label: 'Estimated Value (\$)',
                    icon: Icons.trending_up_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => PopFormValues.validateOptionalMoney(
                      value,
                      fieldLabel: 'Estimated value',
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _pricePaidController,
                    label: 'Price Paid (\$)',
                    icon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => PopFormValues.validateOptionalMoney(
                      value,
                      fieldLabel: 'Price paid',
                    ),
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
