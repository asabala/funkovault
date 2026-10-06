import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/atlas/taxonomy/services/atlas_vault_room_classifier.dart';
import 'package:funkovault2/services/csv_import_service.dart';

void main() {
  test('HobbyDB import preserves Series and classifier derives Vault Room', () {
    const csv =
        '''Name,Brand,Series,HDBC Number,Reference Number,Estimated Value,Quantity\nSpider-Man,Funko,"Pop! Vinyl, Pop! Marvel",HDBC-1,123,25.00,1\n''';

    const importer = CsvImportService();
    const classifier = AtlasVaultRoomClassifier();

    final result = importer.parsePops(csv);

    expect(result.errors, isEmpty);
    expect(result.pops, hasLength(1));

    final pop = result.pops.single;

    // Existing importer behavior remains intact; category is the source brand.
    expect(pop.category, 'Funko');
    expect(pop.series, 'Pop! Vinyl, Pop! Marvel');

    // Vault room identity is derived centrally from preserved source metadata.
    expect(classifier.roomFor(pop), AtlasVaultRoom.marvel);
  });
}
