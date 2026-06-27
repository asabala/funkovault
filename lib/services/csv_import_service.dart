import 'package:csv/csv.dart';

import '../models/pop.dart';

class CsvImportService {
  static List<Pop> importCsv(
      String csvContent,
      ) {
    final rows = const CsvToListConverter(
      eol: '\n',
    ).convert(csvContent);

    if (rows.isEmpty) {
      return [];
    }

    final headers =
    rows.first.map((e) => e.toString()).toList();

    final pops = <Pop>[];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      try {
        final data = <String, dynamic>{};

        for (
        int j = 0;
        j < headers.length && j < row.length;
        j++
        ) {
          data[headers[j]] = row[j];
        }

        final name =
            data['Name']?.toString() ?? '';

        if (name.isEmpty) {
          continue;
        }

        final series =
            data['Series']?.toString() ?? '';

        final number =
            data['Reference Number']
                ?.toString() ??
                '';

        final value = double.tryParse(
          data['Estimated Value']
              ?.toString()
              .replaceAll('\$', '')
              .replaceAll(',', '') ??
              '0',
        ) ??
            0;

        final pricePaid = double.tryParse(
          data['Price Paid']
              ?.toString()
              .replaceAll('\$', '')
              .replaceAll(',', '') ??
              '0',
        ) ??
            0;

        final quantity = int.tryParse(
          data['Quantity']
              ?.toString() ??
              '1',
        ) ??
            1;

        pops.add(
          Pop(
            id: DateTime.now()
                .microsecondsSinceEpoch
                .toString() +
                i.toString(),
            name: name,
            number: number,
            category: '',
            series: series,
            value: value,
            pricePaid: pricePaid,
            quantity: quantity,
            itemCondition:
            data['Item Condition']
                ?.toString() ??
                '',
            boxCondition:
            data['Packaging Condition']
                ?.toString() ??
                '',
            imageUrl:
            data['Image URL']
                ?.toString() ??
                '',
            owner: 'Shared',
            isWishlist: false,
          ),
        );
      } catch (_) {
        continue;
      }
    }

    return pops;
  }
}