// Identifies the scanner implementation or input method that produced
// scan evidence.
//
// Atlas domain models should depend on this type rather than directly
// depending on a specific camera or barcode package.
enum ScannerType {
  mobileScanner,
  mlKit,
  visionKit,
  manualEntry,
  importedData,
  externalProvider,
  unknown,
}

// Presentation and capability helpers for scanner implementations.
extension ScannerTypeX on ScannerType {
  String get label {
    switch (this) {
      case ScannerType.mobileScanner:
        return 'Mobile Scanner';
      case ScannerType.mlKit:
        return 'ML Kit';
      case ScannerType.visionKit:
        return 'Vision Kit';
      case ScannerType.manualEntry:
        return 'Manual Entry';
      case ScannerType.importedData:
        return 'Imported Data';
      case ScannerType.externalProvider:
        return 'External Provider';
      case ScannerType.unknown:
        return 'Unknown';
    }
  }

  bool get usesCamera {
    return this == ScannerType.mobileScanner ||
        this == ScannerType.mlKit ||
        this == ScannerType.visionKit;
  }

  bool get isManual {
    return this == ScannerType.manualEntry;
  }

  bool get isExternal {
    return this == ScannerType.importedData ||
        this == ScannerType.externalProvider;
  }
}
