class Pop {
  final String id;

  final String name;
  final String number;

  final String category;
  final String series;
  final String edition;

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
    required this.edition,
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
    return Pop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      category: json['category'] ?? '',
      series: json['series'] ?? '',
      edition: json['edition'] ?? 'Common',
      value: (json['value'] ?? 0).toDouble(),
      pricePaid: (json['pricePaid'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      itemCondition: json['itemCondition'] ?? '',
      boxCondition: json['boxCondition'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      owner: json['owner'] ?? 'Shared',
      isWishlist: json['isWishlist'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'category': category,
      'series': series,
      'edition': edition,
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