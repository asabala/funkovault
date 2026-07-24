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
import '../../widgets/pop/labeled_dropdown.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class EditPopScreen extends StatefulWidget {
  const EditPopScreen({
    super.key,
    required this.pop,
    this.focusValueField = false,
  });

  final Pop pop;
  final bool focusValueField;

  @override
  State<EditPopScreen> createState() => _EditPopScreenState();
}

class _EditPopScreenState extends State<EditPopScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _valueFocusNode = FocusNode();
  final GlobalKey _valueSectionKey = GlobalKey();

  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _categoryController;
  late TextEditingController _seriesController;
  late TextEditingController _valueController;
  late TextEditingController _pricePaidController;
  late TextEditingController _quantityController;
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

  final List<String> _ownerOptions = const [
    'Arthur',
    'Natacia',
    'Amerika',
    'Nyssa',
    'Angelica',
    'Shared',
  ];

  String _safeOption(
      String value,
      List<String> options,
      String fallback,
      ) {
    return options.contains(value) ? value : fallback;
  }
  bool _isCustomValue(
      String value,
      List<String> options,
      ) {
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
    _pricePaidController =
        TextEditingController(text: widget.pop.pricePaid.toString());
    _quantityController =
        TextEditingController(text: widget.pop.quantity.toString());

    _owner = _safeOption(
      widget.pop.owner,
      _ownerOptions,
      'Shared',
    );

    final savedVariant = widget.pop.variant.trim().isNotEmpty
        ? widget.pop.variant.trim()
        : widget.pop.edition.trim();

    _customVariantController = TextEditingController(
      text: _isCustomValue(
        savedVariant,
        CollectorIdentityOptions.variants,
      )
          ? savedVariant
          : '',
    );

    _variant = _isCustomValue(
      savedVariant,
      CollectorIdentityOptions.variants,
    )
        ? 'Other'
        : _safeOption(
      savedVariant,
      CollectorIdentityOptions.variants,
      'Common',
    );

    _customRetailExclusiveController = TextEditingController(
      text: _isCustomValue(
        widget.pop.retailExclusive,
        CollectorIdentityOptions.retailExclusives,
      )
          ? widget.pop.retailExclusive
          : '',
    );

    _retailExclusive = _isCustomValue(
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
      text: _isCustomValue(
        widget.pop.eventSticker,
        CollectorIdentityOptions.eventStickers,
      )
          ? widget.pop.eventSticker
          : '',
    );

    _eventSticker = _isCustomValue(
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
      text: _isCustomValue(
        widget.pop.limitedEdition,
        CollectorIdentityOptions.limitedEditions,
      )
          ? widget.pop.limitedEdition
          : '',
    );

    _limitedEdition = _isCustomValue(
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
      text: _isCustomValue(
        widget.pop.signature,
        CollectorIdentityOptions.signatures,
      )
          ? widget.pop.signature
          : '',
    );

    _signature = _isCustomValue(
      widget.pop.signature,
      CollectorIdentityOptions.signatures,
    )
        ? 'Other'
        : _safeOption(
      widget.pop.signature,
      CollectorIdentityOptions.signatures,
      'Unsigned',
    );

    if (widget.focusValueField) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusValueSection();
      });
    }
  }

  Future<void> _focusValueSection() async {
    if (!mounted) {
      return;
    }

    final valueSectionContext = _valueSectionKey.currentContext;

    if (valueSectionContext != null) {
      await Scrollable.ensureVisible(
        valueSectionContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.15,
      );
    }

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
    _scrollController.dispose();
    _valueFocusNode.dispose();
    _customVariantController.dispose();
    _customRetailExclusiveController.dispose();
    _customEventStickerController.dispose();
    _customLimitedEditionController.dispose();
    _customSignatureController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
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

    final updatedPop = Pop(
      id: widget.pop.id,
      name: _nameController.text.trim(),
      number: _numberController.text.trim(),
      category: _formatCategory(
        _categoryController.text.trim(),
      ),
      series: _seriesController.text.trim(),
      edition: resolvedVariant,
      variant: resolvedVariant,
      retailExclusive: resolvedRetailExclusive,
      eventSticker: resolvedEventSticker,
      limitedEdition: resolvedLimitedEdition,
      signature: resolvedSignature,
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

    final appState = context.read<AppState>();
    final valueChanged = updatedPop.value != widget.pop.value;

    await appState.updatePop(updatedPop);

    await appState.addActivity(
      Activity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        popId: updatedPop.id,
        action: valueChanged ? 'value_updated' : 'pop_updated',
        popName: updatedPop.name,
        popNumber: updatedPop.number,
        owner: updatedPop.owner,
        actor: updatedPop.owner,
        details: valueChanged
            ? _valueUpdateDetails(
          pop: updatedPop,
          previousValue: widget.pop.value,
        )
            : updatedPop.number.trim().isEmpty
            ? '${updatedPop.name} was updated'
            : '${updatedPop.name} #${updatedPop.number} was updated',
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, updatedPop);
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
          controller: _scrollController,
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
                    _AtlasTextField(
                      controller: _customVariantController,
                      label: 'Custom Variant',
                      icon: Icons.edit_note_rounded,
                    ),
                  ],
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasDropdownPanel(
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
                    _AtlasTextField(
                      controller: _customRetailExclusiveController,
                      label: 'Custom Retail Exclusive',
                      icon: Icons.storefront_outlined,
                    ),
                  ],
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasDropdownPanel(
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
                    _AtlasTextField(
                      controller: _customEventStickerController,
                      label: 'Custom Event Sticker',
                      icon: Icons.local_activity_outlined,
                    ),
                  ],
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasDropdownPanel(
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
                    _AtlasTextField(
                      controller: _customLimitedEditionController,
                      label: 'Custom Limited Edition',
                      icon: Icons.numbers_rounded,
                    ),
                  ],
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasDropdownPanel(
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
                    _AtlasTextField(
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
              key: _valueSectionKey,
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
                    focusNode: _valueFocusNode,
                    label: 'Estimated Value (\$)',
                    icon: Icons.trending_up_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: AtlasSpacing.md),
                  _AtlasTextField(
                    controller: _pricePaidController,
                    label: 'Price Paid (\$)',
                    icon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
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
    this.focusNode,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassPanel(
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
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