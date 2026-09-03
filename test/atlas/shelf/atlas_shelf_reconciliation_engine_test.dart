import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/shelf/engine/atlas_shelf_reconciliation_engine.dart';
import 'package:funkovault2/atlas/shelf/models/atlas_shelf_observation.dart';
import 'package:funkovault2/atlas/shelf/models/atlas_shelf_proposed_action.dart';
import 'package:funkovault2/models/pop.dart';

void main() {
  group('AtlasShelfReconciliationEngine', () {
    const engine = AtlasShelfReconciliationEngine();

    test(
      'owned quantity separates owned physical copies from extra copies',
      () {
        final Pop owned = _pop(id: 'owned', upc: '111111111111', quantity: 1);
        final Pop observed = owned.copyWith(
          id: 'catalog',
          owner: 'Atlas Shelf',
        );
        final DateTime t0 = DateTime.utc(2026, 9, 3, 12);

        final result = engine.reconcile(
          observations: <AtlasShelfObservation>[
            _observation('one', observed, t0),
            _observation('two', observed, t0.add(const Duration(seconds: 1))),
          ],
          collectionPops: <Pop>[owned],
        );

        expect(result.ownedObservationCount, 1);
        expect(result.extraCopyCount, 1);
        expect(result.proposedActions, hasLength(1));
        expect(
          result.proposedActions.single.type,
          AtlasShelfProposedActionType.addAnotherCopy,
        );
      },
    );

    test('related release is possible variant rather than duplicate', () {
      final Pop ownedCommon = _pop(
        id: 'common',
        upc: '222222222222',
        variant: 'Common',
      );
      final Pop observedChase = _pop(
        id: 'chase',
        upc: '222222222222',
        variant: 'Chase',
        owner: 'Atlas Shelf',
      );

      final result = engine.reconcile(
        observations: <AtlasShelfObservation>[
          _observation('variant', observedChase, DateTime.utc(2026, 9, 3, 12)),
        ],
        collectionPops: <Pop>[ownedCommon],
      );

      expect(result.possibleVariantCount, 1);
      expect(result.extraCopyCount, 0);
      expect(
        result.proposedActions.single.type,
        AtlasShelfProposedActionType.reviewVariant,
      );
    });

    test(
      'unowned release stages add action but performs no Vault mutation',
      () {
        final List<Pop> vault = <Pop>[];
        final Pop observed = _pop(
          id: 'new',
          upc: '333333333333',
          owner: 'Atlas Shelf',
        );

        final result = engine.reconcile(
          observations: <AtlasShelfObservation>[
            _observation('new', observed, DateTime.utc(2026, 9, 3, 12)),
          ],
          collectionPops: vault,
        );

        expect(result.notInVaultCount, 1);
        expect(vault, isEmpty);
        expect(
          result.proposedActions.single.requiresExplicitConfirmation,
          isTrue,
        );
        expect(
          result.proposedActions.single.type,
          AtlasShelfProposedActionType.addToVault,
        );
      },
    );

    test('scanner review requirement wins over collector matching', () {
      final Pop owned = _pop(id: 'owned', upc: '444444444444');
      final AtlasShelfObservation observation = _observation(
        'review',
        owned,
        DateTime.utc(2026, 9, 3, 12),
      ).copyWith(resolutionRequiresReview: true);

      final result = engine.reconcile(
        observations: <AtlasShelfObservation>[observation],
        collectionPops: <Pop>[owned],
      );

      expect(result.needsReviewCount, 1);
      expect(
        result.proposedActions.single.type,
        AtlasShelfProposedActionType.reviewObservation,
      );
    });

    test(
      'Vault-owned quantity missing from shelf is separate from completion gaps',
      () {
        final Pop owned = _pop(
          id: 'owned-two',
          upc: '555555555555',
          quantity: 2,
        );

        final result = engine.reconcile(
          observations: <AtlasShelfObservation>[
            _observation('one', owned, DateTime.utc(2026, 9, 3, 12)),
          ],
          collectionPops: <Pop>[owned],
        );

        expect(result.missingFromShelfCount, 1);
        expect(result.completionGaps, isEmpty);
      },
    );
  });
}

AtlasShelfObservation _observation(String id, Pop product, DateTime at) {
  return AtlasShelfObservation(
    observationId: id,
    firstSeenAt: at,
    lastSeenAt: at,
    sourceTrackIds: <String>{'track-$id'},
    activeTrackId: 'track-$id',
    product: product,
    confidence: 1,
  );
}

Pop _pop({
  required String id,
  required String upc,
  int quantity = 1,
  String variant = 'Common',
  String owner = 'Shared',
}) {
  return Pop(
    id: id,
    name: 'Test Pop',
    number: '1',
    category: 'Pop! Heroes',
    series: 'Test Series',
    variant: variant,
    sourceUpc: upc,
    value: 10,
    pricePaid: 0,
    quantity: quantity,
    itemCondition: 'Mint',
    boxCondition: 'Mint',
    imageUrl: '',
    owner: owner,
    isWishlist: false,
  );
}
