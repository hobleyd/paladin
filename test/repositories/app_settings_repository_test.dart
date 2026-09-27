import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/repositories/app_settings_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabase testDb;

  setUp(() async {
    testDb = await TestDatabase.open();
  });

  tearDown(() {
    testDb.dispose();
  });

  test('defaults autoUpdateShelf to true and persists the default row', () async {
    final settings = await testDb.container.read(appSettingsRepositoryProvider.future);
    expect(settings.autoUpdateShelf, isTrue);

    final rows = await testDb.db.query(table: 'app_settings');
    expect(rows, hasLength(1));
    expect(rows.single['auto_update_shelf'], 1);
  });

  test('updateAutoUpdateShelf persists the new value and updates state', () async {
    await testDb.container.read(appSettingsRepositoryProvider.future);

    final notifier = testDb.container.read(appSettingsRepositoryProvider.notifier);
    await notifier.updateAutoUpdateShelf(false);

    expect(testDb.container.read(appSettingsRepositoryProvider).value?.autoUpdateShelf, isFalse);

    final rows = await testDb.db.query(table: 'app_settings');
    expect(rows.single['auto_update_shelf'], 0);
  });

  test('does not insert a second row on later reads', () async {
    await testDb.container.read(appSettingsRepositoryProvider.future);
    await testDb.container.read(appSettingsRepositoryProvider.notifier).updateAutoUpdateShelf(false);

    final rows = await testDb.db.query(table: 'app_settings');
    expect(rows, hasLength(1));
  });
}
