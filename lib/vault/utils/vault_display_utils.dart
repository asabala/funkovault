bool hasMeaningfulVaultValue(String value) {
  final cleaned = value.trim().toLowerCase();

  if (cleaned.isEmpty) {
    return false;
  }

  return cleaned != 'none' &&
      cleaned != 'common' &&
      cleaned != 'standard' &&
      cleaned != 'unsigned' &&
      cleaned != 'no' &&
      cleaned != 'n/a' &&
      cleaned != 'na';
}

String formatVaultDateLabel(String value) {
  final cleaned = value.trim();

  if (cleaned.isEmpty) {
    return 'Before tracking';
  }

  final parsed = DateTime.tryParse(cleaned);

  if (parsed == null) {
    return cleaned;
  }

  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  final year = parsed.year.toString().substring(2);

  return '$month/$day/$year';
}
