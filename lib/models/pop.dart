class Pop {
  final String id;

  final String name;
  final String number;

  final String category;
  final String series;

  final String edition;
  final String variant;
  final String retailExclusive;
  final String eventSticker;
  final String limitedEdition;
  final String signature;

  final double value;
  final double pricePaid;

  final int quantity;

  final String itemCondition;
  final String boxCondition;

  final String imageUrl;

  final String owner;

  final bool isWishlist;

  const Pop({
    required this.id,
    required this.name,
    required this.number,
    required this.category,
    required this.series,
    this.edition = 'Common',
    this.variant = 'Common',
    this.retailExclusive = 'None',
    this.eventSticker = 'None',
    this.limitedEdition = 'None',
    this.signature = 'Unsigned',
    required this.value,
    required this.pricePaid,
    required this.quantity,
    required this.itemCondition,
    required this.boxCondition,
    required this.imageUrl,
    required this.owner,
    required this.isWishlist,
  });

  factory Pop.fromJson(
      Map<String, dynamic> json,
      ) {
    final legacyEdition =
        json['edition'] ?? 'Common';

    return Pop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      category: json['category'] ?? '',
      series: json['series'] ?? '',
      edition: legacyEdition,
      variant: json['variant'] ?? legacyEdition,
      retailExclusive:
      json['retailExclusive'] ?? 'None',
      eventSticker:
      json['eventSticker'] ?? 'None',
      limitedEdition:
      json['limitedEdition'] ?? 'None',
      signature: json['signature'] ?? 'Unsigned',
      value: (json['value'] ?? 0).toDouble(),
      pricePaid:
      (json['pricePaid'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      itemCondition:
      json['itemCondition'] ?? '',
      boxCondition:
      json['boxCondition'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      owner: json['owner'] ?? 'Shared',
      isWishlist:
      json['isWishlist'] ?? false,
    );
  }

  String get collectorIdentity {
    return [
      name,
      number,
      variant,
      retailExclusive,
      eventSticker,
      limitedEdition,
      signature,
    ]
        .map((value) => value.trim().toLowerCase())
        .join('|');
  }

  String get collectorLabel {
    final parts = <String>[
      variant,
      retailExclusive,
      eventSticker,
      limitedEdition,
      signature,
    ].where(
          (value) =>
      value.trim().isNotEmpty &&
          value != 'None' &&
          value != 'Unsigned',
    );

    if (parts.isEmpty) {
      return 'Common';
    }

    return parts.join(' • ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'category': category,
      'series': series,
      'edition': edition,
      'variant': variant,
      'retailExclusive': retailExclusive,
      'eventSticker': eventSticker,
      'limitedEdition': limitedEdition,
      'signature': signature,
      'value': value,
      'pricePaid': pricePaid,
      'quantity': quantity,
      'itemCondition': itemCondition,
      'boxCondition': boxCondition,
      'imageUrl': imageUrl,
      'owner': owner,
      'isWishlist': isWishlist,
    };
  }
}