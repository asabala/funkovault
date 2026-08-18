import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/market/models/value_history_entry.dart';
import 'package:funkovault2/atlas/timeline/models/atlas_timeline_event.dart';
import 'package:funkovault2/models/pop.dart';

void main() {
  final historyEntry = ValueHistoryEntry(
    value: 25,
    recordedAt: DateTime.utc(2026, 1),
  );
  final timelineEvent = AtlasTimelineEvent(
    id: 'event-1',
    popId: 'pop-1',
    type: AtlasTimelineEventType.custom,
    occurredAt: DateTime.utc(2026, 1),
    title: 'Existing event',
  );

  final pop = Pop(
    id: 'pop-1',
    name: 'Batman',
    number: '01',
    category: 'Heroes',
    series: 'Batman',
    edition: 'First Edition',
    variant: 'Common',
    retailExclusive: 'Target',
    eventSticker: 'SDCC',
    limitedEdition: 'LE 1000',
    signature: 'Signed',
    sourceCatalogId: 'ATLAS-FNK-000001',
    sourceCollectibleId: 'source-1',
    sourceUpc: '889698000001',
    productionStatus: 'Vaulted',
    releaseDate: '2010-01-01',
    gradingCompany: 'PSA',
    authenticityNumber: 'AUTH-1',
    finish: 'Standard',
    size: '4 Inch',
    packagingType: 'Single',
    boxVersion: 'US',
    copyrightYear: '2010',
    productionCode: 'PROD-1',
    stickerType: 'Convention',
    authenticationProvider: 'JSA',
    value: 25,
    pricePaid: 10,
    valueHistory: [historyEntry],
    timeline: [timelineEvent],
    quantity: 1,
    itemCondition: 'Mint',
    boxCondition: 'Near Mint',
    imageUrl: 'https://images.example/batman.png',
    owner: 'Imported Owner',
    isWishlist: false,
    dateAdded: '2026-01-01T00:00:00.000Z',
    lastUpdated: '2026-02-01T00:00:00.000Z',
  );

  test('copyWith preserves every omitted serialized field', () {
    final updated = pop.copyWith(name: 'Batman Updated');
    final expected = pop.toJson()..['name'] = 'Batman Updated';

    expect(updated.toJson(), expected);
    expect(updated.edition, 'First Edition');
    expect(updated.valueHistory, same(pop.valueHistory));
    expect(updated.timeline, same(pop.timeline));
  });

  test('physical-release differences remain distinct exact identities', () {
    final distinctReleases = <Pop>[
      pop.copyWith(edition: 'Second Edition'),
      pop.copyWith(variant: 'Chase'),
      pop.copyWith(finish: 'Metallic'),
      pop.copyWith(retailExclusive: 'Hot Topic'),
      pop.copyWith(eventSticker: 'NYCC'),
      pop.copyWith(stickerType: 'Shared'),
      pop.copyWith(limitedEdition: 'LE 500'),
      pop.copyWith(signature: 'Unsigned'),
      pop.copyWith(authenticationProvider: 'Beckett'),
      pop.copyWith(gradingCompany: 'CGC'),
      pop.copyWith(authenticityNumber: 'AUTH-2'),
      pop.copyWith(size: '6 Inch'),
      pop.copyWith(packagingType: 'Two Pack'),
      pop.copyWith(boxVersion: 'International'),
      pop.copyWith(copyrightYear: '2011'),
      pop.copyWith(productionCode: 'PROD-2'),
    ];

    for (final release in distinctReleases) {
      expect(release.name, pop.name);
      expect(release.number, pop.number);
      expect(release.collectibleIdentityKey, isNot(pop.collectibleIdentityKey));
    }
  });

  test('collection record identity protects owner and wishlist state', () {
    expect(
      pop.copyWith(owner: 'Another Owner').collectionRecordKey,
      isNot(pop.collectionRecordKey),
    );
    expect(
      pop.copyWith(isWishlist: true).collectionRecordKey,
      isNot(pop.collectionRecordKey),
    );
  });
}
