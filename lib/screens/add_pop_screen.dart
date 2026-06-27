import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pop.dart';
import '../models/funko_catalog_item.dart';
import '../services/app_state.dart';

class AddPopScreen extends StatefulWidget {
  final FunkoCatalogItem? catalogItem;

  const AddPopScreen({
    super.key,
    this.catalogItem,
  });

  @override
  State<AddPopScreen> createState() =>
      _AddPopScreenState();
}

class _AddPopScreenState
    extends State<AddPopScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
  TextEditingController();
  final _numberController =
  TextEditingController();
  final _categoryController =
  TextEditingController();
  final _seriesController =
  TextEditingController();
  final _editionController =
  TextEditingController(text: 'Common');
  final _valueController =
  TextEditingController();
  final _pricePaidController =
  TextEditingController();
  final _quantityController =
  TextEditingController(text: '1');

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

  String _formatEdition(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return 'Common';
    }

    const upperEditions = {
      'nycc': 'NYCC',
      'sdcc': 'SDCC',
      'eccc': 'ECCC',
      'px': 'PX',
    };

    final lower = trimmed.toLowerCase();

    if (upperEditions.containsKey(lower)) {
      return upperEditions[lower]!;
    }

    return trimmed
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
        _seriesController.text =
            item.series.first;

        _categoryController.text =
            item.series.first;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _categoryController.dispose();
    _seriesController.dispose();
    _editionController.dispose();
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
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      name: _nameController.text.trim(),
      number: _numberController.text.trim(),
      category: _formatCategory(
        _categoryController.text.trim(),
      ),
      series: _seriesController.text.trim(),
      edition: _formatEdition(
        _editionController.text,
      ),
      value:
      double.tryParse(_valueController.text) ??
          0,
      pricePaid: double.tryParse(
        _pricePaidController.text,
      ) ??
          0,
      quantity:
      int.tryParse(_quantityController.text) ??
          1,
      itemCondition: '',
      boxCondition: '',
      imageUrl:
      widget.catalogItem?.imageName ?? '',
      owner: 'Shared',
      isWishlist: false,
    );

    context.read<AppState>().addPop(pop);

    Navigator.pop(context);
  }

  void _showCategoryHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Category Examples'),
        content: const Text(
          'Examples:\n\n'
              '• DC\n'
              '• Marvel\n'
              '• Horror\n'
              '• Anime\n'
              '• Disney\n'
              '• Star Wars\n'
              '• WWE',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditionHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edition Examples'),
        content: const Text(
          'Examples:\n\n'
              '• Common\n'
              '• Chase\n'
              '• Glow\n'
              '• Blacklight\n'
              '• Flocked\n'
              '• Metallic\n'
              '• Funko Shop\n'
              '• Hot Topic\n'
              '• Target\n'
              '• Walmart\n'
              '• Amazon\n'
              '• PX\n'
              '• SDCC\n'
              '• NYCC\n'
              '• ECCC\n'
              '• Shared Exclusive\n'
              '• Signed',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Funko Pop'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                decoration: InputDecoration(
                  labelText: 'Category',
                  border:
                  const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                    ),
                    onPressed: _showCategoryHelp,
                  ),
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

              const SizedBox(height: 16),

              TextFormField(
                controller: _editionController,
                decoration: InputDecoration(
                  labelText: 'Edition / Sticker',
                  hintText: 'Common, Chase, Funko Shop, SDCC',
                  border:
                  const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                    ),
                    onPressed: _showEditionHelp,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimated Value',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _pricePaidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price Paid',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _savePop,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Pop'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}