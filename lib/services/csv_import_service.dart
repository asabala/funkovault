import '../models/pop.dart';

class CsvImportParseResult {
  const CsvImportParseResult({
    required this.pops,
    required this.skippedRows,
    required this.errors,
  });

  final List<Pop> pops;
  final int skippedRows;
  final List<String> errors;

  int get parsedRows => pops.length;
  int get totalIssues => skippedRows + errors.length;
}

class CsvImportService {
  const CsvImportService();

  CsvImportParseResult importCsv(String rawContent) {
    return parsePops(rawContent);
  }

  CsvImportParseResult parsePops(String rawContent) {
    final lines = rawContent
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const CsvImportParseResult(
        pops: [],
        skippedRows: 0,
        errors: ['The import file is empty.'],
      );
    }

    final delimiter = _detectDelimiter(lines.first);
    final headers = _parseLine(lines.first, delimiter)
        .map(_normalizeHeader)
        .toList();

    final pops = <Pop>[];
    final errors = <String>[];
    var skippedRows = 0;

    for (var index = 1; index < lines.length; index++) {
      final rowNumber = index + 1;
      final values = _parseLine(lines[index], delimiter);

      if (values.every((value) => value.trim().isEmpty)) {
        skippedRows++;
        continue;
      }

      final row = _buildRowMap(headers, values);
      final name = _read(row, 'name');

      if (name.isEmpty) {
        skippedRows++;
        errors.add('Row $rowNumber skipped: missing Name.');
        continue;
      }

      pops.add(
        Pop(
          id: _read(row, 'hdbid').isEmpty
              ? _generatedId(rowNumber)
              : _read(row, 'hdbid'),
          name: name,
          number: _read(row, 'reference number'),
          category: _firstNotEmpty([
            _read(row, 'brand'),
            _read(row, 'series'),
            'Unknown',
          ]),
          series: _read(row, 'series'),
          retailExclusive: _firstNotEmpty([
            _read(row, 'exclusive to'),
            'None',
          ]),
          value: _parseMoney(_read(row, 'estimated value')),
          pricePaid: _parseMoney(_read(row, 'price paid')),
          quantity: _parseQuantity(_read(row, 'quantity')),
          itemCondition: _read(row, 'item condition'),
          boxCondition: _read(row, 'packaging condition'),
          imageUrl: _read(row, 'image url'),
          owner: _firstNotEmpty([
            _read(row, 'list name'),
            'Shared',
          ]),
          isWishlist: _isWishlistRow(row),
        ),
      );
    }

    return CsvImportParseResult(
      pops: pops,
      skippedRows: skippedRows,
      errors: errors,
    );
  }

  String _detectDelimiter(String headerLine) {
    if (headerLine.contains('\t')) {
      return '\t';
    }

    return ',';
  }

  List<String> _parseLine(String line, String delimiter) {
    if (delimiter == '\t') {
      return line.split('\t');
    }

    return _parseCsvLine(line);
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var insideQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final character = line[i];

      if (character == '"') {
        final isEscapedQuote =
            insideQuotes && i + 1 < line.length && line[i + 1] == '"';

        if (isEscapedQuote) {
          buffer.write('"');
          i++;
        } else {
          insideQuotes = !insideQuotes;
        }

        continue;
      }

      if (character == ',' && !insideQuotes) {
        values.add(buffer.toString());
        buffer.clear();
        continue;
      }

      buffer.write(character);
    }

    values.add(buffer.toString());

    return values;
  }

  Map<String, String> _buildRowMap(
      List<String> headers,
      List<String> values,
      ) {
    final row = <String, String>{};

    for (var index = 0; index < headers.length; index++) {
      final value = index < values.length ? values[index].trim() : '';

      row[headers[index]] = value;
    }

    return row;
  }

  String _read(
      Map<String, String> row,
      String key,
      ) {
    return row[_normalizeHeader(key)]?.trim() ?? '';
  }

  String _normalizeHeader(String value) {
    return value.trim().toLowerCase();
  }

  String _firstNotEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  double _parseMoney(String value) {
    final cleaned = value
        .replaceAll(r'$', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  int _parseQuantity(String value) {
    final parsed = int.tryParse(value.trim());

    if (parsed == null || parsed <= 0) {
      return 1;
    }

    return parsed;
  }

  bool _isWishlistRow(Map<String, String> row) {
    final listName = _read(row, 'list name').toLowerCase();
    final privateNotes = _read(row, 'private notes').toLowerCase();
    final description = _read(row, 'description').toLowerCase();

    return listName.contains('wishlist') ||
        privateNotes.contains('wishlist') ||
        description.contains('wishlist');
  }

  String _generatedId(int rowNumber) {
    return 'csv-${DateTime.now().millisecondsSinceEpoch}-$rowNumber';
  }
}