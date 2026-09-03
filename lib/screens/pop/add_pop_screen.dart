import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../atlas/engines/intelligence/atlas_insight_engine.dart';
import '../../atlas/engines/intelligence/atlas_recommendation_engine.dart';
import '../../atlas/services/atlas_activity_service.dart';
import '../../atlas/widgets/atlas_insight_card.dart';
import '../../constants/collector_identity_options.dart';
import '../../atlas/catalog/models/atlas_catalog_product.dart';
import '../../atlas/catalog/services/atlas_pop_factory.dart';
import '../../atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/atlas_glass_panel.dart';
import '../../widgets/atlas/atlas_expandable_section.dart';
import '../../widgets/atlas/components/atlas_dropdown_panel.dart';
import '../../widgets/atlas/components/atlas_form_field.dart';
import '../../widgets/atlas/components/atlas_product_image.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/pop/labeled_dropdown.dart';
import '../../widgets/pop/pop_form.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class AddPopScreen extends StatefulWidget {
  const AddPopScreen({
    super.key,
    this.atlasProduct,
    this.collectionName,
    this.visualInspection,
  });

  final AtlasCatalogProduct? atlasProduct;
  final String? collectionName;
  final AtlasVisualInspection? visualInspection;

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
  final _itemConditionController = TextEditingController();
  final _boxConditionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _customVariantController = TextEditingController();
  final _customRetailExclusiveController = TextEditingController();
  final _customEventStickerController = TextEditingController();
  final _customLimitedEditionController = TextEditingController();
  final _customSignatureController = TextEditingController();
  final _productionCodeController = TextEditingController();
  final _copyrightYearController = TextEditingController();
  final _stickerTypeController = TextEditingController();
  final _authenticationProviderController = TextEditingController();
  final _authenticityNumberController = TextEditingController();

  String _variant = 'Common';
  String _retailExclusive = 'None';
  String _eventSticker = 'None';
  String _limitedEdition = 'None';
  String _signature = 'Unsigned';

  bool get _hasCatalogProduct {
    return widget.atlasProduct != null;
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

  String _catalogIdentitySelection({
    required String value,
    required List<String> options,
    required String fallback,
    required TextEditingController customController,
  }) {
    final String normalized = value.trim();

    if (normalized.isEmpty) {
      return fallback;
    }

    if (options.contains(normalized)) {
      return normalized;
    }

    customController.text = normalized;

    return 'Other';
  }

  @override
  void initState() {
    super.initState();

    final AtlasCatalogProduct? product = widget.atlasProduct;

    final inspection = widget.visualInspection;
    if (inspection != null) {
      _productionCodeController.text = inspection.productionStampText;
      _copyrightYearController.text = inspection.copyrightText;
      _stickerTypeController.text = inspection.stickerText;
      _authenticationProviderController.text =
          inspection.authenticationProvider;
      _authenticityNumberController.text = inspection.authenticityNumber;
      if (inspection.signature.trim().isNotEmpty) {
        _customSignatureController.text = inspection.signature.trim();
        _signature = 'Other';
      }
    }

    if (product == null) {
      return;
    }

    final catalogPop = AtlasPopFactory.createFromCatalog(product: product);

    _nameController.text = catalogPop.name;
    _numberController.text = catalogPop.number;
    _categoryController.text = _formatCategory(catalogPop.category);
    _seriesController.text = catalogPop.series;
    _itemConditionController.text = catalogPop.itemCondition;
    _boxConditionController.text = catalogPop.boxCondition;
    _imageUrlController.text = catalogPop.imageUrl;

    if (catalogPop.value > 0) {
      _valueController.text = catalogPop.value.toStringAsFixed(2);
    }

    _variant = _catalogIdentitySelection(
      value: catalogPop.variant,
      options: CollectorIdentityOptions.variants,
      fallback: 'Common',
      customController: _customVariantController,
    );
    _retailExclusive = _catalogIdentitySelection(
      value: catalogPop.retailExclusive,
      options: CollectorIdentityOptions.retailExclusives,
      fallback: 'None',
      customController: _customRetailExclusiveController,
    );
    _eventSticker = _catalogIdentitySelection(
      value: catalogPop.eventSticker,
      options: CollectorIdentityOptions.eventStickers,
      fallback: 'None',
      customController: _customEventStickerController,
    );
    _limitedEdition = _catalogIdentitySelection(
      value: catalogPop.limitedEdition,
      options: CollectorIdentityOptions.limitedEditions,
      fallback: 'None',
      customController: _customLimitedEditionController,
    );
    _signature = _catalogIdentitySelection(
      value: catalogPop.signature,
      options: CollectorIdentityOptions.signatures,
      fallback: 'Unsigned',
      customController: _customSignatureController,
    );

    if (inspection != null && inspection.signature.trim().isNotEmpty) {
      _customSignatureController.text = inspection.signature.trim();
      _signature = 'Other';
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
    _itemConditionController.dispose();
    _boxConditionController.dispose();
    _imageUrlController.dispose();
    _customVariantController.dispose();
    _customRetailExclusiveController.dispose();
    _customEventStickerController.dispose();
    _customLimitedEditionController.dispose();
    _customSignatureController.dispose();
    _productionCodeController.dispose();
    _copyrightYearController.dispose();
    _stickerTypeController.dispose();
    _authenticationProviderController.dispose();
    _authenticityNumberController.dispose();
    super.dispose();
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

  Future<void> _savePop() async {
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

    final selectedSignature = _resolvedIdentityValue(
      selectedValue: _signature,
      customController: _customSignatureController,
      fallback: 'Unsigned',
    );
    final resolvedSignature = _customSignatureController.text.trim().isNotEmpty
        ? _customSignatureController.text.trim()
        : selectedSignature;

    final double value = PopFormValues.parseOptionalMoney(
      _valueController.text,
    );

    final double pricePaid = PopFormValues.parseOptionalMoney(
      _pricePaidController.text,
    );

    final int quantity = PopFormValues.parseQuantity(_quantityController.text);

    final AtlasCatalogProduct? product = widget.atlasProduct;

    final pop = product == null
        ? AtlasPopFactory.createManual(
            name: _nameController.text,
            number: _numberController.text,
            category: _formatCategory(_categoryController.text.trim()),
            series: _seriesController.text,
            variant: resolvedVariant,
            retailExclusive: resolvedRetailExclusive,
            eventSticker: resolvedEventSticker,
            limitedEdition: resolvedLimitedEdition,
            signature: resolvedSignature,
            productionCode: _productionCodeController.text,
            copyrightYear: _copyrightYearController.text,
            stickerType: _stickerTypeController.text,
            authenticationProvider: _authenticationProviderController.text,
            authenticityNumber: _authenticityNumberController.text,
            value: value,
            pricePaid: pricePaid,
            quantity: quantity,
            itemCondition: _itemConditionController.text,
            boxCondition: _boxConditionController.text,
            imageUrl: _imageUrlController.text,
            owner: 'Shared',
            isWishlist: false,
          )
        : AtlasPopFactory.createFromCatalog(
            product: product,
            name: _nameController.text,
            number: _numberController.text,
            category: _formatCategory(_categoryController.text.trim()),
            series: _seriesController.text,
            variant: resolvedVariant,
            retailExclusive: resolvedRetailExclusive,
            eventSticker: resolvedEventSticker,
            limitedEdition: resolvedLimitedEdition,
            signature: resolvedSignature,
            productionCode: _productionCodeController.text,
            copyrightYear: _copyrightYearController.text,
            stickerType: _stickerTypeController.text,
            authenticationProvider: _authenticationProviderController.text,
            authenticityNumber: _authenticityNumberController.text,
            value: value,
            pricePaid: pricePaid,
            quantity: quantity,
            itemCondition: _itemConditionController.text,
            boxCondition: _boxConditionController.text,
            imageUrl: _imageUrlController.text,
            owner: 'Shared',
            isWishlist: false,
          );

    final added = await context.read<AppState>().addPop(
      pop,
      collectionName: widget.collectionName,
    );

    if (!added) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This collection could not be found. The Pop was not added.',
            ),
          ),
        );
      }

      return;
    }

    AtlasActivityService.record(
      title: 'Pop Added',
      description: '${pop.name} #${pop.number} was added to the Vault.',
      type: 'pop_added',
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
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
      appBar: AppBar(title: const Text('Add Funko Pop')),
      body: Form(
        key: _formKey,
        child: VaultScrollView(
          children: [
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Pop', style: AtlasTypography.headingLarge),
                  const SizedBox(height: AtlasSpacing.sm),
                  Text(
                    'Add a new Pop to your current vault. Atlas will save the added date and updated date automatically.',
                    style: AtlasTypography.bodyMedium.copyWith(
                      color: AtlasColors.textSecondary,
                    ),
                  ),
                  if (_hasCatalogProduct) ...[
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
                                  widget.atlasProduct!.displayName,
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
            AtlasExpandableSection(
              title: 'Authenticity & Details',
              subtitle:
                  'Production, copyright, sticker, autograph, and COA evidence.',
              icon: Icons.verified_user_outlined,
              child: Column(
                children: [
                  AtlasFormField(
                    controller: _productionCodeController,
                    label: 'Production Code',
                    icon: Icons.factory_outlined,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _copyrightYearController,
                    label: 'Copyright Year',
                    icon: Icons.copyright_rounded,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _stickerTypeController,
                    label: 'Sticker Type',
                    icon: Icons.sell_outlined,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _customSignatureController,
                    label: 'Signature Details',
                    icon: Icons.draw_outlined,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _authenticationProviderController,
                    label: 'Authentication Provider',
                    icon: Icons.verified_outlined,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _authenticityNumberController,
                    label: 'Authenticity Number',
                    icon: Icons.numbers_rounded,
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
                    subtitle: 'Enter the core identity of this collectible.',
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
                  const AtlasSectionHeader(
                    title: 'Collector Identity',
                    subtitle:
                        'Capture variants, exclusives, stickers, limited editions, and signatures.',
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
                      hintText: 'Enter the variant type',
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
                      hintText: 'Enter the store or retailer',
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
                      hintText: 'Enter the event or sticker',
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
                      hintText: 'Example: LE 1250',
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
                      hintText: 'Enter signer or authentication details',
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
                    title: 'Value',
                    subtitle: 'Track estimated market value and what you paid.',
                    icon: Icons.attach_money_rounded,
                    accentColor: AtlasColors.vaultGold,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _valueController,
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
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AtlasSectionHeader(
                    title: 'Ownership',
                    subtitle:
                        'Record how many identical physical copies you own.',
                    icon: Icons.inventory_2_rounded,
                    accentColor: AtlasColors.vaultGold,
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  AtlasFormField(
                    controller: _quantityController,
                    label: 'Quantity',
                    icon: Icons.format_list_numbered_rounded,
                    keyboardType: TextInputType.number,
                    validator: PopFormValues.validateQuantity,
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
            const SizedBox(height: AtlasSpacing.lg),
            AtlasGlassCard(
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
