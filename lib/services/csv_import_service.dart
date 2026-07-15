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

  int get totalPhysicalCopies {
    return pops.fold<int>(
      0,
          (total, pop) => total + pop.quantity,
    );
  }
}

class CsvImportService {
  const CsvImportService();

  CsvImportParseResult importCsv(String rawContent) {
    return parsePops(rawContent);
  }

  CsvImportParseResult parsePops(String rawContent) {
    final lines = rawContent
        .split(RegExp(r'\r?\n'))
        .where(
          (line) => line.trim().isNotEmpty,
    )
        .toList();

    if (lines.isEmpty) {
      return const CsvImportParseResult(
        pops: [],
        skippedRows: 0,
        errors: ['The import file is empty.'],
      );
    }

    final delimiter = _detectDelimiter(
      lines.first,
    );

    final headers = _parseLine(
      lines.first,
      delimiter,
    )
        .map(_normalizeHeader)
        .toList();

    final pops = <Pop>[];
    final errors = <String>[];
    var skippedRows = 0;

    for (var index = 1; index < lines.length; index++) {
      final rowNumber = index + 1;

      final values = _parseLine(
        lines[index],
        delimiter,
      );

      if (values.every(
            (value) => value.trim().isEmpty,
      )) {
        skippedRows++;
        continue;
      }

      final row = _buildRowMap(
        headers,
        values,
      );

      final name = _read(
        row,
        'Name',
      );

      if (name.isEmpty) {
        skippedRows++;

        errors.add(
          'Row $rowNumber skipped: missing Name.',
        );

        continue;
      }

      final hdbId = _read(
        row,
        'HDBID',
      );

      final hdbcNumber = _read(
        row,
        'HDBC Number',
      );

      final productionStatus = _read(
        row,
        'Production Status',
      );

      final gradingCompany = _read(
        row,
        'Grading Company',
      );

      final authenticityNumber = _read(
        row,
        'Grade Authenticity Number',
      );

      final description = _read(
        row,
        'Description',
      );

      final moreDetails = _read(
        row,
        'More Details',
      );

      final privateNotes = _read(
        row,
        'Private Notes',
      );

      final combinedDetails = [
        name,
        productionStatus,
        gradingCompany,
        authenticityNumber,
        description,
        moreDetails,
        privateNotes,
      ].join(' ');

      final variant = _resolveVariant(
        productionStatus: productionStatus,
        combinedDetails: combinedDetails,
      );

      final edition = _resolveEdition(
        productionStatus: productionStatus,
        variant: variant,
      );

      final retailExclusive = _firstNotEmpty(
        [
          _read(
            row,
            'Exclusive To',
          ),
          'None',
        ],
      );

      final eventSticker = _resolveSticker(
        row: row,
        combinedDetails: combinedDetails,
      );

      final limitedEdition = _resolveLimitedEdition(
        productionStatus: productionStatus,
        combinedDetails: combinedDetails,
      );

      final signature = _resolveSignature(
        gradingCompany: gradingCompany,
        authenticityNumber: authenticityNumber,
        combinedDetails: combinedDetails,
      );

      pops.add(
        Pop(
          // HDBC Number identifies this specific collector record.
          // It is safer than HDBID for editing and deleting one owned copy.
          id: hdbcNumber.isNotEmpty
              ? hdbcNumber
              : _generatedId(
            rowNumber,
          ),
          name: name,
          number: _read(
            row,
            'Reference Number',
          ),
          category: _firstNotEmpty(
            [
              _read(
                row,
                'Brand',
              ),
              _read(
                row,
                'Series',
              ),
              'Unknown',
            ],
          ),
          series: _read(
            row,
            'Series',
          ),
          edition: edition,
          variant: variant,
          retailExclusive: retailExclusive,
          eventSticker: eventSticker,
          limitedEdition: limitedEdition,
          signature: signature,

          // HobbyDB source identity.
          sourceCatalogId: hdbId,
          sourceCollectibleId: hdbcNumber,
          sourceUpc: _read(
            row,
            'UPC',
          ),
          productionStatus: productionStatus,
          releaseDate: _read(
            row,
            'Release Date',
          ),
          gradingCompany: gradingCompany,
          authenticityNumber: authenticityNumber,

          value: _parseMoney(
            _read(
              row,
              'Estimated Value',
            ),
          ),
          pricePaid: _parseMoney(
            _read(
              row,
              'Price Paid',
            ),
          ),
          quantity: _parseQuantity(
            _read(
              row,
              'Quantity',
            ),
          ),
          itemCondition: _read(
            row,
            'Item Condition',
          ),
          boxCondition: _read(
            row,
            'Packaging Condition',
          ),
          imageUrl: _read(
            row,
            'Image URL',
          ),
          owner: _firstNotEmpty(
            [
              _read(
                row,
                'List Name',
              ),
              'Shared',
            ],
          ),
          isWishlist: _isWishlistRow(
            row,
          ),
          dateAdded: _normalizeImportedDate(
            _read(
              row,
              'Date Added To Collectible',
            ),
          ),
        ),
      );
    }

    return CsvImportParseResult(
      pops: pops,
      skippedRows: skippedRows,
      errors: errors,
    );
  }

  String _resolveVariant({
    required String productionStatus,
    required String combinedDetails,
  }) {
    final statusParts = productionStatus
        .split(',')
        .map(
          (value) => value.trim(),
    )
        .where(
          (value) => value.isNotEmpty,
    )
        .toList();

    final normalizedStatuses = statusParts
        .map(
          (value) => value.toLowerCase(),
    )
        .toSet();

    // Chase must take priority over Standard.
    if (normalizedStatuses.contains('chase')) {
      return 'Chase';
    }

    if (normalizedStatuses.contains('deluxe')) {
      return 'Deluxe';
    }

    if (normalizedStatuses.contains('reproduction')) {
      return 'Reproduction';
    }

    final detectedVariant = _detectVariantFromText(
      combinedDetails,
    );

    if (detectedVariant != null) {
      return detectedVariant;
    }

    return 'Common';
  }

  String _resolveEdition({
    required String productionStatus,
    required String variant,
  }) {
    final cleanedStatus = productionStatus.trim();

    if (cleanedStatus.isNotEmpty) {
      return cleanedStatus;
    }

    return variant;
  }

  String _resolveSticker({
    required Map<String, String> row,
    required String combinedDetails,
  }) {
    // The current HobbyDB export has no dedicated sticker column.
    // We only use explicit text when it is actually present.
    final detectedSticker = _detectStickerFromText(
      combinedDetails,
    );

    if (detectedSticker != null) {
      return detectedSticker;
    }

    final exclusiveTo = _read(
      row,
      'Exclusive To',
    );

    final productionStatus = _read(
      row,
      'Production Status',
    ).toLowerCase();

    if (exclusiveTo.isNotEmpty &&
        productionStatus.contains('exclusive')) {
      return '$exclusiveTo Exclusive';
    }

    return 'None';
  }

  String _resolveLimitedEdition({
    required String productionStatus,
    required String combinedDetails,
  }) {
    final detectedPieceCount = _detectPieceCount(
      combinedDetails,
    );

    if (detectedPieceCount != null) {
      return detectedPieceCount;
    }

    if (productionStatus
        .toLowerCase()
        .contains('limited edition')) {
      return 'Limited Edition';
    }

    return 'None';
  }

  String _resolveSignature({
    required String gradingCompany,
    required String authenticityNumber,
    required String combinedDetails,
  }) {
    if (gradingCompany.trim().isNotEmpty ||
        authenticityNumber.trim().isNotEmpty) {
      final details = <String>[
        if (gradingCompany.trim().isNotEmpty)
          gradingCompany.trim(),
        if (authenticityNumber.trim().isNotEmpty)
          authenticityNumber.trim(),
      ];

      return details.isEmpty
          ? 'Signed'
          : 'Signed • ${details.join(' • ')}';
    }

    final lowerDetails = combinedDetails.toLowerCase();

    if (lowerDetails.contains('autographed') ||
        lowerDetails.contains('autograph') ||
        lowerDetails.contains('signed by') ||
        RegExp(r'\bsigned\b').hasMatch(lowerDetails)) {
      return 'Signed';
    }

    return 'Unsigned';
  }

  String? _detectVariantFromText(String value) {
    final lowerValue = value.toLowerCase();

    const patterns = <String, String>{
      'black light': 'Blacklight',
      'blacklight': 'Blacklight',
      'glow in the dark': 'Glow',
      'glow-in-the-dark': 'Glow',
      'gitd': 'Glow',
      'diamond collection': 'Diamond',
      'metallic': 'Metallic',
      'flocked': 'Flocked',
      'chrome': 'Chrome',
      'patina': 'Patina',
      'translucent': 'Translucent',
      'black and white': 'Black & White',
      'black & white': 'Black & White',
      'sepia': 'Sepia',
      'bloody': 'Bloody',
      'battle damaged': 'Battle Damaged',
      'unmasked': 'Unmasked',
    };

    for (final entry in patterns.entries) {
      if (lowerValue.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  String? _detectStickerFromText(String value) {
    final lowerValue = value.toLowerCase();

    const patterns = <String, String>{
      'official convention sticker':
      'Official Convention Sticker',
      'convention exclusive sticker':
      'Convention Exclusive Sticker',
      'shared exclusive sticker':
      'Shared Exclusive Sticker',
      'shared sticker':
      'Shared Exclusive Sticker',
      'special edition sticker':
      'Special Edition Sticker',
      'funko shop sticker':
      'Funko Shop Sticker',
      'limited edition sticker':
      'Limited Edition Sticker',
    };

    for (final entry in patterns.entries) {
      if (lowerValue.contains(entry.key)) {
        return entry.value;
      }
    }

    final conventionMatch = RegExp(
      r'\b(sdcc|nycc|ecc|wondercon|fundays|funkon)\b',
      caseSensitive: false,
    ).firstMatch(
      value,
    );

    if (conventionMatch != null) {
      return '${conventionMatch.group(0)!.toUpperCase()} Sticker';
    }

    return null;
  }

  String? _detectPieceCount(String value) {
    final match = RegExp(
      r'\b(?:limited\s*(?:edition)?\s*)?'
      r'(\d{2,6})\s*(?:pcs|pieces|piece)\b',
      caseSensitive: false,
    ).firstMatch(
      value,
    );

    if (match == null) {
      return null;
    }

    return '${match.group(1)} Pieces';
  }

  String _detectDelimiter(String headerLine) {
    if (headerLine.contains('\t')) {
      return '\t';
    }

    return ',';
  }

  List<String> _parseLine(
      String line,
      String delimiter,
      ) {
    if (delimiter == '\t') {
      return line.split('\t');
    }

    return _parseCsvLine(
      line,
    );
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var insideQuotes = false;

    for (var index = 0; index < line.length; index++) {
      final character = line[index];

      if (character == '"') {
        final hasEscapedQuote = insideQuotes &&
            index + 1 < line.length &&
            line[index + 1] == '"';

        if (hasEscapedQuote) {
          buffer.write('"');
          index++;
        } else {
          insideQuotes = !insideQuotes;
        }

        continue;
      }

      if (character == ',' && !insideQuotes) {
        values.add(
          buffer.toString(),
        );

        buffer.clear();
        continue;
      }

      buffer.write(
        character,
      );
    }

    values.add(
      buffer.toString(),
    );

    return values;
  }

  Map<String, String> _buildRowMap(
      List<String> headers,
      List<String> values,
      ) {
    final row = <String, String>{};

    for (var index = 0; index < headers.length; index++) {
      final value =
      index < values.length ? values[index].trim() : '';

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

    return double.tryParse(
      cleaned,
    ) ??
        0;
  }

  int _parseQuantity(String value) {
    final parsed = int.tryParse(
      value.trim(),
    );

    if (parsed == null || parsed <= 0) {
      return 1;
    }

    return parsed;
  }

  String _normalizeImportedDate(String value) {
    final cleaned = value.trim();

    if (cleaned.isEmpty) {
      return '';
    }

    final directParsed = DateTime.tryParse(
      cleaned,
    );

    if (directParsed != null) {
      return directParsed.toIso8601String();
    }

    final parts = cleaned.split('/');

    if (parts.length == 3) {
      final year = int.tryParse(
        parts[0],
      );

      final month = int.tryParse(
        parts[1],
      );

      final day = int.tryParse(
        parts[2],
      );

      if (year != null && month != null && day != null) {
        return DateTime(
          year,
          month,
          day,
        ).toIso8601String();
      }
    }

    return cleaned;
  }

  bool _isWishlistRow(Map<String, String> row) {
    final listName = _read(
      row,
      'List Name',
    ).toLowerCase();

    final privateNotes = _read(
      row,
      'Private Notes',
    ).toLowerCase();

    final description = _read(
      row,
      'Description',
    ).toLowerCase();

    return listName.contains('wishlist') ||
        privateNotes.contains('wishlist') ||
        description.contains('wishlist');
  }

  String _generatedId(int rowNumber) {
    return 'csv-${DateTime.now().microsecondsSinceEpoch}-$rowNumber';
  }
}