class FunkoCatalogItem {
  final String handle;
  final String title;
  final String imageName;
  final List<String> series;

  const FunkoCatalogItem({
    required this.handle,
    required this.title,
    required this.imageName,
    required this.series,
  });

  factory FunkoCatalogItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return FunkoCatalogItem(
      handle: json['handle'] ?? '',
      title: json['title'] ?? '',
      imageName:
      json['imageName'] ?? '',
      series:
      (json['series'] as List?)
          ?.map(
            (e) =>
            e.toString(),
      )
          .toList() ??
          [],
    );
  }
}