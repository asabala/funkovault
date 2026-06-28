import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pop.dart';
import '../models/funko_catalog_item.dart';
import '../services/app_state.dart';
import '../widgets/form_section_title.dart';
import '../widgets/labeled_dropdown.dart';
import '../atlas/widgets/atlas_insight_card.dart';
import '../atlas/engines/atlas_insight_engine.dart';
import '../atlas/engines/atlas_recommendation_engine.dart';
import '../atlas/services/atlas_activity_service.dart';

class AddPopScreen extends StatefulWidget {
  final FunkoCatalogItem? catalogItem;

  const AddPopScreen({
    super.key,
    this.catalogItem,
  });

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

  void _savePop() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
    );

    context.read<AppState>().addPop(pop);

    AtlasActivityService.record(
      title: 'Pop Added',
      description:
      '${pop.name} #${pop.number} was added to the Vault.',
      type: 'pop_added',
    );
    Navigator.pop(context);
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
        title: const Text('Add Funko Pop'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const FormSectionTitle(
                  'Basic Information',
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
                    hintText: 'Pop! Marvel',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                const FormSectionTitle(
                  'Collector Identity',
                ),

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

                const FormSectionTitle(
                  'Value',
                ),

                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Value (\$)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _pricePaidController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price Paid (\$)',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                const FormSectionTitle(
                  'Ownership',
                ),

                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
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
              onPressed: _savePop,
              icon: const Icon(Icons.save),
              label: const Text('Save Pop'),
            ),
          ),
        ),
      ),
    );
  }
}