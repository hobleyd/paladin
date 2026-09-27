import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/repositories/calibre_server_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabase testDb;

  setUp(() async {
    testDb = await TestDatabase.open();
  });

  tearDown(() {
    testDb.dispose();
  });

  test('defaults to an empty server and lastConnected 0 when nothing is stored', () async {
    final server = await testDb.container.read(calibreServerRepositoryProvider.future);

    expect(server.calibreServer, '');
    expect(server.lastConnected, 0);
  });

  test('updateServerDetails persists and reflects partial updates', () async {
    await testDb.container.read(calibreServerRepositoryProvider.future);
    final notifier = testDb.container.read(calibreServerRepositoryProvider.notifier);

    await notifier.updateServerDetails(calibreServer: 'https://calibre.example.com', lastConnected: 1000);
    expect(testDb.container.read(calibreServerRepositoryProvider).value?.calibreServer, 'https://calibre.example.com');
    expect(testDb.container.read(calibreServerRepositoryProvider).value?.lastConnected, 1000);

    // Updating just one field should not clobber the other.
    await notifier.updateServerDetails(lastConnected: 2000);
    expect(testDb.container.read(calibreServerRepositoryProvider).value?.calibreServer, 'https://calibre.example.com');
    expect(testDb.container.read(calibreServerRepositoryProvider).value?.lastConnected, 2000);
  });

  test('updateServerDetails persists across a fresh read from the database', () async {
    await testDb.container.read(calibreServerRepositoryProvider.future);
    await testDb.container.read(calibreServerRepositoryProvider.notifier).updateServerDetails(calibreServer: 'https://calibre.example.com', lastConnected: 1000);

    final rows = await testDb.db.query(table: 'calibre_library');
    expect(rows.single['calibre_server'], 'https://calibre.example.com');
    expect(rows.single['last_connected'], 1000);
  });
}
