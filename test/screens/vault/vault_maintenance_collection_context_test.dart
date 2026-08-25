import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/models/pop.dart';
import 'package:funkovault2/screens/vault/vault_maintenance_screen.dart';
import 'package:funkovault2/services/app_state.dart';
import 'package:provider/provider.dart';

class _VaultMaintenanceTestAppState extends AppState {
  String _selectedCollection = 'Clear Target';

  final Map<String, List<Pop>> _testCollections = {
    'Clear Target': <Pop>[
      Pop(
        id: 'clear-me',
        name: 'Clear Me',
        number: '01',
        category: 'Heroes',
        series: 'Test',
        value: 20,
        pricePaid: 10,
        quantity: 1,
        itemCondition: 'Mint',
        boxCondition: 'Mint',
        imageUrl: '',
        owner: 'Clear Target',
        isWishlist: false,
      ),
    ],
    'Keep Collection': <Pop>[
      Pop(
        id: 'keep-me',
        name: 'Keep Me',
        number: '02',
        category: 'Heroes',
        series: 'Test',
        value: 20,
        pricePaid: 10,
        quantity: 1,
        itemCondition: 'Mint',
        boxCondition: 'Mint',
        imageUrl: '',
        owner: 'Keep Collection',
        isWishlist: false,
      ),
    ],
  };

  String? requestedClearCollection;

  @override
  String get selectedCollection => _selectedCollection;

  @override
  List<Pop> get selectedCollectionPops {
    return List<Pop>.unmodifiable(
      _testCollections[_selectedCollection] ?? const <Pop>[],
    );
  }

  @override
  List<Pop> popsForCollection(String collectionName) {
    return List<Pop>.unmodifiable(
      _testCollections[collectionName] ?? const <Pop>[],
    );
  }

  @override
  Future<CollectionOperationResult> setSelectedCollection(String value) async {
    _selectedCollection = value;
    notifyListeners();
    return CollectionOperationResult.success;
  }

  @override
  Future<bool> clearCollection(String collectionName) async {
    requestedClearCollection = collectionName;

    final pops = _testCollections[collectionName];

    if (pops == null) {
      return false;
    }

    pops.clear();
    notifyListeners();

    return true;
  }
}

void main() {
  testWidgets(
    'Vault Maintenance clears collection captured before confirmation',
    (tester) async {
      final state = _VaultMaintenanceTestAppState();

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 3000);

      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
        state.dispose();
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: VaultMaintenanceScreen()),
        ),
      );

      await tester.pump();

      final clearAction = find.text('Clear Current Collection');

      await tester.scrollUntilVisible(clearAction, 500);

      expect(clearAction, findsOneWidget);

      await tester.tap(clearAction);
      await tester.pumpAndSettle();

      expect(find.text('Clear Current Collection?'), findsOneWidget);

      expect(find.textContaining('"Clear Target"'), findsOneWidget);

      await state.setSelectedCollection('Keep Collection');

      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Clear Collection'));

      await tester.pumpAndSettle();

      expect(state.requestedClearCollection, 'Clear Target');

      expect(state.popsForCollection('Clear Target'), isEmpty);

      expect(state.popsForCollection('Keep Collection'), hasLength(1));

      expect(state.selectedCollection, 'Keep Collection');

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
