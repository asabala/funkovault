final class ProductUpsertResult {
  const ProductUpsertResult({
    required this.productId,
    required this.inserted,
  });

  final int productId;
  final bool inserted;
}