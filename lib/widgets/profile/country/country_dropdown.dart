import 'package:flutter/material.dart';

import '../../../data/country_registry.dart';
import '../../../models/country_option.dart';

class CountryDropdown extends StatelessWidget {
  const CountryDropdown({
    required this.selectedCountry,
    required this.onChanged,
    super.key,
  });

  final CountryOption selectedCountry;
  final ValueChanged<CountryOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CountryOption>(
      initialValue: selectedCountry,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Country',
        prefixIcon: Icon(Icons.public),
      ),
      items: CountryRegistry.all.map((country) {
        return DropdownMenuItem(
          value: country,
          child: Text(
            '${country.flag} ${country.name}',
          ),
        );
      }).toList(),
      onChanged: (country) {
        if (country != null) {
          onChanged(country);
        }
      },
    );
  }
}