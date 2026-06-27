import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pop.dart';
import '../services/app_state.dart';

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

class _EditPopScreenState
    extends State<EditPopScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _categoryController;
  late TextEditingController _seriesController;
  late TextEditingController _editionController;
  late TextEditingController _valueController;
  late TextEditingController _pricePaidController;
  late TextEditingController _quantityController;

  late String _owner;

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

    _nameController =
        TextEditingController(
          text: widget.pop.name,
        );

    _numberController =
        TextEditingController(
          text: widget.pop.number,
        );

    _categoryController =
        TextEditingController(
          text: widget.pop.category,
        );

    _seriesController =
        TextEditingController(
          text: widget.pop.series,
        );

    _editionController =
        TextEditingController(
          text: widget.pop.edition.isEmpty
              ? 'Common'
              : widget.pop.edition,
        );

    _valueController =
        TextEditingController(
          text: widget.pop.value.toString(),
        );

    _pricePaidController =
        TextEditingController(
          text: widget.pop.pricePaid.toString(),
        );

    _quantityController =
        TextEditingController(
          text: widget.pop.quantity.toString(),
        );

    _owner = widget.pop.owner;
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

  void _saveChanges() {
    final updatedPop = Pop(
      id: widget.pop.id,
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
      quantity: int.tryParse(
        _quantityController.text,
      ) ??
          1,
      itemCondition: widget.pop.itemCondition,
      boxCondition: widget.pop.boxCondition,
      imageUrl: widget.pop.imageUrl,
      owner: _owner,
      isWishlist: widget.pop.isWishlist,
    );

    context.read<AppState>().updatePop(
      updatedPop,
    );

    Navigator.pop(
      context,
      updatedPop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pop'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                const InputDecoration(
                  labelText: 'Pop Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _numberController,
                decoration:
                const InputDecoration(
                  labelText: 'Pop Number',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _owner,
                decoration:
                const InputDecoration(
                  labelText: 'Owner',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Arthur',
                    child: Text('Arthur'),
                  ),
                  DropdownMenuItem(
                    value: 'Natacia',
                    child: Text('Natacia'),
                  ),
                  DropdownMenuItem(
                    value: 'Amerika',
                    child: Text('Amerika'),
                  ),
                  DropdownMenuItem(
                    value: 'Nyssa',
                    child: Text('Nyssa'),
                  ),
                  DropdownMenuItem(
                    value: 'Angelica',
                    child: Text('Angelica'),
                  ),
                  DropdownMenuItem(
                    value: 'Shared',
                    child: Text('Shared'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _owner = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _categoryController,
                decoration:
                const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _seriesController,
                decoration:
                const InputDecoration(
                  labelText: 'Series',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _editionController,
                decoration:
                const InputDecoration(
                  labelText: 'Edition / Sticker',
                  hintText:
                  'Common, Chase, Funko Shop, SDCC',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _valueController,
                keyboardType:
                TextInputType.number,
                decoration:
                const InputDecoration(
                  labelText:
                  'Estimated Value (\$)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _pricePaidController,
                keyboardType:
                TextInputType.number,
                decoration:
                const InputDecoration(
                  labelText:
                  'Price Paid (\$)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                _quantityController,
                keyboardType:
                TextInputType.number,
                decoration:
                const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child:
                ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon:
                  const Icon(Icons.save),
                  label: const Text(
                    'Save Changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}