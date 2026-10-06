import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/taxonomy/services/atlas_vault_room_classifier.dart';
import 'package:funkovault2/models/pop.dart';

void main() {
  const classifier = AtlasVaultRoomClassifier();

  Pop pop({
    required String name,
    required String series,
    String category = 'Funko',
    bool isWishlist = false,
  }) {
    return Pop(
      id: '$name-$series',
      name: name,
      number: '1',
      category: category,
      series: series,
      value: 10,
      pricePaid: 0,
      quantity: 1,
      itemCondition: 'Mint',
      boxCondition: 'Mint',
      imageUrl: '',
      owner: 'Shared',
      isWishlist: isWishlist,
    );
  }

  test('HobbyDB Marvel series resolves even when category is Funko', () {
    final item = pop(name: 'Spider-Man', series: 'Pop! Vinyl, Pop! Marvel');

    expect(classifier.roomFor(item), AtlasVaultRoom.marvel);
  });

  test('Star Wars and Games use high-confidence series signals', () {
    expect(
      classifier.roomFor(
        pop(name: 'Darth Vader', series: 'Pop! Vinyl, Pop! Star Wars'),
      ),
      AtlasVaultRoom.starWars,
    );

    expect(
      classifier.roomFor(
        pop(name: 'Master Chief', series: 'Pop! Vinyl, Pop! Games'),
      ),
      AtlasVaultRoom.gaming,
    );
  });

  test('Pop Heroes routes to DC', () {
    expect(
      classifier.roomFor(
        pop(name: 'Batman 1989', series: 'Pop! Heroes, Pop! Vinyl'),
      ),
      AtlasVaultRoom.dc,
    );
  });

  test('ambiguous Animation uses character evidence for Anime', () {
    expect(
      classifier.roomFor(
        pop(name: 'Soba Mask', series: 'Pop! Animation, Pop! Vinyl'),
      ),
      AtlasVaultRoom.anime,
    );

    expect(
      classifier.roomFor(
        pop(name: 'Igris', series: 'Pop! Animation, Pop! Vinyl'),
      ),
      AtlasVaultRoom.anime,
    );
  });

  test('western Animation does not become Anime', () {
    expect(
      classifier.roomFor(
        pop(
          name: 'Snoopy in Penalty Box',
          series: 'Pop! Animation, Pop! Vinyl',
        ),
      ),
      AtlasVaultRoom.moviesAndTv,
    );

    expect(
      classifier.roomFor(
        pop(name: 'Alastor', series: 'Pop! Animation, Pop! Vinyl'),
      ),
      AtlasVaultRoom.moviesAndTv,
    );
  });

  test('Disney and Television override generic Animation fallback', () {
    expect(
      classifier.roomFor(
        pop(name: 'Stitch', series: 'Pop! Animation, Pop! Disney'),
      ),
      AtlasVaultRoom.moviesAndTv,
    );

    expect(
      classifier.roomFor(
        pop(name: 'Share Bear', series: 'Pop! Animation, Pop! Television'),
      ),
      AtlasVaultRoom.moviesAndTv,
    );
  });

  test('expanded taxonomy promotes common HobbyDB lines', () {
    expect(
      classifier.roomFor(
        pop(name: 'Freddie Mercury', series: 'Pop! Rocks, Pop! Vinyl'),
      ),
      AtlasVaultRoom.music,
    );
    expect(
      classifier.roomFor(
        pop(name: 'Geno Smith', series: 'Pop! Vinyl, Pop! Football'),
      ),
      AtlasVaultRoom.sports,
    );
    expect(
      classifier.roomFor(
        pop(name: 'Cherry Nerd', series: 'Pop! Vinyl, Pop! Ad Icons'),
      ),
      AtlasVaultRoom.icons,
    );
    expect(
      classifier.roomFor(
        pop(name: 'Optimus Prime', series: 'Pop! Vinyl, Pop! Retro Toys'),
      ),
      AtlasVaultRoom.retroToys,
    );
    expect(
      classifier.roomFor(
        pop(name: 'Farmer Freddy', series: 'Pop! Vinyl, Pop! Originals'),
      ),
      AtlasVaultRoom.originals,
    );
    expect(
      classifier.roomFor(
        pop(name: 'Essence Derecognize', series: 'Pop! Vinyl, Pop! Asia'),
      ),
      AtlasVaultRoom.asiaInternational,
    );
  });

  test('franchise aliases repair generic HobbyDB format rows', () {
    expect(
      classifier.roomFor(
        pop(name: 'Loki', series: 'Pop! Vinyl, Pop! Limited Edition'),
      ),
      AtlasVaultRoom.marvel,
    );
    expect(
      classifier.roomFor(
        pop(name: 'Megatron', series: 'Pop! Vinyl, Pop! Limited Edition'),
      ),
      AtlasVaultRoom.moviesAndTv,
    );
    expect(
      classifier.roomFor(
        pop(
          name: 'Aisha',
          series: 'Pop! Vinyl, Power Rangers X Funko Series 2',
        ),
      ),
      AtlasVaultRoom.moviesAndTv,
    );
    expect(
      classifier.roomFor(
        pop(name: 'Griphook', series: 'Pop! Vinyl, Pop! Harry Potter'),
      ),
      AtlasVaultRoom.moviesAndTv,
    );
    expect(
      classifier.roomFor(
        pop(name: 'Dr. Hooves', series: 'Pop! Vinyl, Pop! My Little Pony'),
      ),
      AtlasVaultRoom.moviesAndTv,
    );
    expect(
      classifier.roomFor(
        pop(name: 'The Young Bucks', series: 'Pop! Vinyl, Pop! Wrestling'),
      ),
      AtlasVaultRoom.sports,
    );
  });

  test(
    'Pop Plus and Rides only inherit Anime from known franchise identities',
    () {
      for (final name in <String>[
        'Monkey D. Luffy',
        'Mitsuri Kanroji',
        'Tanjiro',
        'Silvers Raleigh',
        'Nezuko Kamado',
        'Gyokko',
        'Shanks',
      ]) {
        expect(
          classifier.roomFor(pop(name: name, series: 'Pop! Vinyl, Pop! Plus')),
          AtlasVaultRoom.anime,
        );
      }

      expect(
        classifier.roomFor(
          pop(name: 'Unknown Plus Item', series: 'Pop! Vinyl, Pop! Plus'),
        ),
        AtlasVaultRoom.other,
      );
    },
  );

  test(
    'format-only lines remain Other without reliable franchise evidence',
    () {
      for (final series in <String>[
        'Soda Figures',
        'Dorbz',
        'Pop! Vinyl, Pop! Plants',
        'Pop! Vinyl, Pop! Around the World',
        'Bitty Pop!',
        'Pop! Vinyl, Pop! Sanrio',
      ]) {
        expect(
          classifier.roomFor(pop(name: 'Unknown Format Item', series: series)),
          AtlasVaultRoom.other,
        );
      }
    },
  );

  test(
    'generic limited-edition Dungeons and Dragons item can use exact alias',
    () {
      expect(
        classifier.roomFor(
          pop(
            name: 'Red Dragon Wyrmling',
            series: 'Pop! Vinyl, Pop! Limited Edition',
          ),
        ),
        AtlasVaultRoom.gaming,
      );
    },
  );

  test('unmatched collectibles still resolve to Other', () {
    expect(
      classifier.roomFor(
        pop(name: 'Mystery Collectible', series: 'Pop! Vinyl'),
      ),
      AtlasVaultRoom.other,
    );
  });

  test('room counts are mutually exclusive and ignore wishlist records', () {
    final pops = <Pop>[
      pop(name: 'Spider-Man', series: 'Pop! Marvel'),
      pop(name: 'Darth Vader', series: 'Pop! Star Wars'),
      pop(name: 'Batman', series: 'Pop! Heroes'),
      pop(name: 'Igris', series: 'Pop! Animation'),
      pop(name: 'Snoopy', series: 'Pop! Animation'),
      pop(name: 'Master Chief', series: 'Pop! Games'),
      pop(name: 'Freddie Mercury', series: 'Pop! Rocks'),
      pop(name: 'Geno Smith', series: 'Pop! Football'),
      pop(name: 'Farmer Freddy', series: 'Pop! Originals'),
      pop(name: 'Wishlist Marvel', series: 'Pop! Marvel', isWishlist: true),
    ];

    final counts = classifier.countsFor(pops);
    final total = counts.values.fold<int>(0, (sum, count) => sum + count);

    expect(total, 9);
    expect(counts[AtlasVaultRoom.anime], 1);
    expect(counts[AtlasVaultRoom.marvel], 1);
    expect(counts[AtlasVaultRoom.dc], 1);
    expect(counts[AtlasVaultRoom.starWars], 1);
    expect(counts[AtlasVaultRoom.moviesAndTv], 1);
    expect(counts[AtlasVaultRoom.gaming], 1);
    expect(counts[AtlasVaultRoom.sports], 1);
    expect(counts[AtlasVaultRoom.music], 1);
    expect(counts[AtlasVaultRoom.originals], 1);
    expect(counts[AtlasVaultRoom.other], 0);
  });

  test('final audited aliases classify confirmed HobbyDB edge cases', () {
    final cases = <({String name, String series, AtlasVaultRoom room})>[
      (
        name: 'Lucy',
        series: 'Pop! Vinyl, Pop! Plus',
        room: AtlasVaultRoom.moviesAndTv,
      ),
      (
        name: 'Ham',
        series: 'Pop! Vinyl, Pop! Limited Edition',
        room: AtlasVaultRoom.moviesAndTv,
      ),
      (
        name: 'Crying Demon',
        series: 'Pop! Vinyl, Pop! Mystery',
        room: AtlasVaultRoom.moviesAndTv,
      ),
      (
        name: 'Loot',
        series: 'Pop! Vinyl, Pop! Limited Edition',
        room: AtlasVaultRoom.gaming,
      ),
      (
        name: 'NCR Power Armor',
        series: 'Pop! Vinyl, Pop! Limited Edition',
        room: AtlasVaultRoom.gaming,
      ),
      (
        name: 'Donald (Kingdom Hearts)',
        series: 'GameStop, Electronic Entertainment Expo, Pop! Pez',
        room: AtlasVaultRoom.gaming,
      ),
      (
        name: 'Sora (Monsters, Inc.)',
        series: 'Hot Topic, BoxLunch, Pocket Pop! Keychain',
        room: AtlasVaultRoom.gaming,
      ),
      (
        name: 'Kitsune Mask Franny',
        series: 'Pop! Vinyl, Pop! Digital, Funko x Funime and Cosplay',
        room: AtlasVaultRoom.originals,
      ),
      (
        name: 'Ultimate Freddy',
        series: 'Pop! Vinyl, Pop! Digital, Funko x Funime and Cosplay',
        room: AtlasVaultRoom.originals,
      ),
      (
        name: 'Sabretooth',
        series: 'Pop! Vinyl, Pop! Comic Covers',
        room: AtlasVaultRoom.marvel,
      ),
      (
        name: 'Connor Hawke',
        series: 'Pop! Vinyl, Pop! Digital, DC x Funko: Series 2',
        room: AtlasVaultRoom.dc,
      ),
      (
        name: 'Cal Raleigh',
        series: 'Pop! Vinyl, Pop! MLB',
        room: AtlasVaultRoom.sports,
      ),
      (
        name: 'Snoop Dogg',
        series: 'Gold, Gold Music',
        room: AtlasVaultRoom.music,
      ),
    ];

    for (final item in cases) {
      expect(
        classifier.roomFor(pop(name: item.name, series: item.series)),
        item.room,
        reason: '${item.name} should resolve to ${item.room.displayName}',
      );
    }
  });

  test('audited specialty Board Games item remains Other', () {
    expect(
      classifier.roomFor(
        pop(name: 'La Muerte', series: 'Pop! Vinyl, Pop! Board Games'),
      ),
      AtlasVaultRoom.other,
    );
  });
}
