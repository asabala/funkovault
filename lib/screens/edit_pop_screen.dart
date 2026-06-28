import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../atlas/engines/atlas_insight_engine.dart';
import '../atlas/engines/atlas_recommendation_engine.dart';
import '../atlas/widgets/atlas_insight_card.dart';
import '../models/pop.dart';
import '../services/app_state.dart';
import '../widgets/form_section_title.dart';
import '../widgets/labeled_dropdown.dart';
import '../atlas/services/atlas_activity_service.dart';

class EditPopScreen extends StatefulWidget {
  final Pop pop;

  const EditPopScreen({
    super.key,
    required this.pop,
  });

  @override
  State<EditPopScreen> createState() =>
      _EditPopScreenState();
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
    if (value.isEmpty) return '';

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
          : word[0].toUpperCase() +
          word.substring(1).toLowerCase(),
    )
        .join(' ');
  }

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.pop.name);
    _numberController =
        TextEditingController(text: widget.pop.number);
    _categoryController =
        TextEditingController(text: widget.pop.category);
    _seriesController =
        TextEditingController(text: widget.pop.series);
    _valueController =
        TextEditingController(text: widget.pop.value.toString());
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
      widget.pop.edition.isNotEmpty
          ? widget.pop.edition
          : 'Common',
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

  void _saveChanges() {
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
      pricePaid:
      double.tryParse(_pricePaidController.text) ?? 0,
      quantity:
      int.tryParse(_quantityController.text) ?? 1,
      itemCondition: widget.pop.itemCondition,
      boxCondition: widget.pop.boxCondition,
      imageUrl: widget.pop.imageUrl,
      owner: _owner,
      isWishlist: widget.pop.isWishlist,
    );

    context.read<AppState>().updatePop(updatedPop);

    AtlasActivityService.record(
      title: 'Pop Updated',
      description:
      '${updatedPop.name} #${updatedPop.number} was updated.',
      type: 'pop_updated',
    );
    Navigator.pop(context, updatedPop);
  }

  @override
  Widget build(BuildContext context) {
    const insightEngine = AtlasInsightEngine();

    final collectorInsight =
    insightEngine.buildCollectorIdentityInsight(
      variant: _variant,
      retailExclusive: _retailExclusive,
      eventSticker: _eventSticker,
      limitedEdition: _limitedEdition,
      signature: _signature,
    );

    const recommendationEngine =
    AtlasRecommendationEngine();

    final collectorRecommendation =
    recommendationEngine
        .buildCollectorIdentityRecommendation(
      variant: _variant,
      retailExclusive: _retailExclusive,
      eventSticker: _eventSticker,
      limitedEdition: _limitedEdition,
      signature: _signature,
      value: double.tryParse(_valueController.text) ?? 0,
      pricePaid:
      double.tryParse(_pricePaidController.text) ?? 0,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Edit Pop'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding:
          const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const FormSectionTitle(
                  'Basic Information',
                ),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pop Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    labelText: 'Pop Number',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _seriesController,
                  decoration: const InputDecoration(
                    labelText: 'Series',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                const FormSectionTitle(
                  'Collector Identity',
                ),

                AtlasInsightCard(
                  title: collectorInsight.title,
                  message: collectorInsight.message,
                ),

                if (collectorRecommendation != null) ...[
                  const SizedBox(height: 12),
                  AtlasInsightCard(
                    title: collectorRecommendation.title,
                    message: collectorRecommendation.message,
                    icon: Icons.lightbulb_outline,
                  ),
                ],

                const SizedBox(height: 16),

                LabeledDropdown(
                  label: 'Variant',
                  value: _variant,
                  options: _variantOptions,
                  onChanged: (value) {
                    setState(() {
                      _variant = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                LabeledDropdown(
                  label: 'Retail Exclusive',
                  value: _retailExclusive,
                  options: _retailOptions,
                  onChanged: (value) {
                    setState(() {
                      _retailExclusive = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                LabeledDropdown(
                  label: 'Event Sticker',
                  value: _eventSticker,
                  options: _eventOptions,
                  onChanged: (value) {
                    setState(() {
                      _eventSticker = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                LabeledDropdown(
                  label: 'Limited Edition',
                  value: _limitedEdition,
                  options: _limitedOptions,
                  onChanged: (value) {
                    setState(() {
                      _limitedEdition = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                LabeledDropdown(
                  label: 'Signature',
                  value: _signature,
                  options: _signatureOptions,
                  onChanged: (value) {
                    setState(() {
                      _signature = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                const FormSectionTitle('Ownership'),

                LabeledDropdown(
                  label: 'Owner',
                  value: _owner,
                  options: _ownerOptions,
                  onChanged: (value) {
                    setState(() {
                      _owner = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                const FormSectionTitle('Value'),

                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Value (\$)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _pricePaidController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price Paid (\$)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
            ),
          ),
        ),
      ),
    );
  }
}