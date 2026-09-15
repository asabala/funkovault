class CollectorProfile {
  const CollectorProfile({
    required this.id,
    required this.atlasId,
    required this.displayName,
    required this.collectorTitle,
    required this.collectorMotto,
    required this.bio,
    required this.favoriteCategory,
    required this.favoriteFranchise,
    required this.dreamGrail,
    required this.country,
    required this.countryCode,
    required this.countryFlag,
    required this.avatarUrl,
    required this.bannerUrl,
    required this.collectorLevel,
    required this.joinYear,
    required this.isPremium,
  });

  final String id;
  final String atlasId;
  final String displayName;
  final String collectorTitle;
  final String collectorMotto;
  final String bio;
  final String favoriteCategory;
  final String favoriteFranchise;
  final String dreamGrail;
  final String country;
  final String countryCode;
  final String countryFlag;
  final String avatarUrl;
  final String bannerUrl;
  final String collectorLevel;
  final int joinYear;
  final bool isPremium;

  factory CollectorProfile.fromJson(Map<String, dynamic> json) {
    return CollectorProfile(
      id: json['id'] ?? 'default',
      atlasId: json['atlasId'] ?? 'ATL-000001',
      displayName: json['displayName'] ?? 'Arthur',
      collectorTitle: json['collectorTitle'] ?? 'Atlas Collector',
      collectorMotto: json['collectorMotto'] ?? 'Collector. Curator. Explorer.',
      bio: json['bio'] ?? 'Building a collection one Pop at a time.',
      favoriteCategory: json['favoriteCategory'] ?? 'Marvel',
      favoriteFranchise: json['favoriteFranchise'] ?? 'Spider-Man',
      dreamGrail: json['dreamGrail'] ?? 'Planet Arlia Vegeta',
      country: json['country'] ?? 'United States',
      countryCode: json['countryCode'] ?? 'US',
      countryFlag: json['countryFlag'] ?? '🇺🇸',
      avatarUrl: json['avatarUrl'] ?? '',
      bannerUrl: json['bannerUrl'] ?? '',
      collectorLevel: json['collectorLevel'] ?? 'Rookie',
      joinYear: json['joinYear'] ?? DateTime.now().year,
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'atlasId': atlasId,
      'displayName': displayName,
      'collectorTitle': collectorTitle,
      'collectorMotto': collectorMotto,
      'bio': bio,
      'favoriteCategory': favoriteCategory,
      'favoriteFranchise': favoriteFranchise,
      'dreamGrail': dreamGrail,
      'country': country,
      'countryCode': countryCode,
      'countryFlag': countryFlag,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'collectorLevel': collectorLevel,
      'joinYear': joinYear,
      'isPremium': isPremium,
    };
  }

  CollectorProfile copyWith({
    String? id,
    String? atlasId,
    String? displayName,
    String? collectorTitle,
    String? collectorMotto,
    String? bio,
    String? favoriteCategory,
    String? favoriteFranchise,
    String? dreamGrail,
    String? country,
    String? countryCode,
    String? countryFlag,
    String? avatarUrl,
    String? bannerUrl,
    String? collectorLevel,
    int? joinYear,
    bool? isPremium,
  }) {
    return CollectorProfile(
      id: id ?? this.id,
      atlasId: atlasId ?? this.atlasId,
      displayName: displayName ?? this.displayName,
      collectorTitle: collectorTitle ?? this.collectorTitle,
      collectorMotto: collectorMotto ?? this.collectorMotto,
      bio: bio ?? this.bio,
      favoriteCategory: favoriteCategory ?? this.favoriteCategory,
      favoriteFranchise: favoriteFranchise ?? this.favoriteFranchise,
      dreamGrail: dreamGrail ?? this.dreamGrail,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      countryFlag: countryFlag ?? this.countryFlag,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      collectorLevel: collectorLevel ?? this.collectorLevel,
      joinYear: joinYear ?? this.joinYear,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
