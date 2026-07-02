import '../models/country_option.dart';

class CountryRegistry {
  const CountryRegistry._();

  static const defaultCountry = CountryOption(
    name: 'United States',
    code: 'US',
    flag: '🇺🇸',
  );

  static const all = [
    defaultCountry,
    CountryOption(
      name: 'Mexico',
      code: 'MX',
      flag: '🇲🇽',
    ),
    CountryOption(
      name: 'Canada',
      code: 'CA',
      flag: '🇨🇦',
    ),
    CountryOption(
      name: 'Japan',
      code: 'JP',
      flag: '🇯🇵',
    ),
    CountryOption(
      name: 'United Kingdom',
      code: 'GB',
      flag: '🇬🇧',
    ),
    CountryOption(
      name: 'France',
      code: 'FR',
      flag: '🇫🇷',
    ),
    CountryOption(
      name: 'Germany',
      code: 'DE',
      flag: '🇩🇪',
    ),
    CountryOption(
      name: 'Brazil',
      code: 'BR',
      flag: '🇧🇷',
    ),
    CountryOption(
      name: 'Spain',
      code: 'ES',
      flag: '🇪🇸',
    ),
    CountryOption(
      name: 'Italy',
      code: 'IT',
      flag: '🇮🇹',
    ),
  ];

  static CountryOption findByCode(String code) {
    final normalizedCode = code.trim().toUpperCase();

    return all.firstWhere(
          (country) => country.code == normalizedCode,
      orElse: () => defaultCountry,
    );
  }

  static CountryOption findByName(String name) {
    final normalizedName = name.trim().toLowerCase();

    return all.firstWhere(
          (country) => country.name.toLowerCase() == normalizedName,
      orElse: () => defaultCountry,
    );
  }
}