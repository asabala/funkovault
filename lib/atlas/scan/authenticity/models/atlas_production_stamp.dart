final class AtlasProductionStamp {
  const AtlasProductionStamp({
    required this.rawInput,
    required this.factoryCode,
    required this.productionDate,
    required this.itemBatch,
    required this.isValid,
  });

  final String rawInput;
  final String factoryCode;
  final DateTime? productionDate;
  final String? itemBatch;
  final bool isValid;
}
