import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/collection.dart';
import 'package:paladin/repositories/shelf_repository.dart';

import '../helpers/keep_alive.dart';
import '../helpers/test_database.dart';

void main() {
  late TestDatabase testDb;

  setUp(() async {
    testDb = await TestDatabase.open();
  });

  tearDown(() {
    testDb.dispose();
  });

  test('build reads the "Currently Reading" shelf LibraryDB creates on first run', () async {
    keepAlive(testDb.container, shelfRepositoryProvider(1));
    final shelf = await testDb.container.read(shelfRepositoryProvider(1).future);

    expect(shelf.shelfId, 1);
    expect(shelf.name, 'Currently Reading');
    expect(shelf.type, CollectionType.CURRENT);
  });

  test('build falls back to an unsaved RANDOM shelf for an unknown shelfId', () async {
    keepAlive(testDb.container, shelfRepositoryProvider(999));
    final shelf = await testDb.container.read(shelfRepositoryProvider(999).future);

    expect(shelf.shelfId, 999);
    expect(shelf.type, CollectionType.RANDOM);

    final rows = await testDb.db.query(table: 'shelves', where: 'rowid = ?', whereArgs: [999]);
    expect(rows, isEmpty);
  });

  test('updateShelfName persists the new name', () async {
    keepAlive(testDb.container, shelfRepositoryProvider(2));
    await testDb.container.read(shelfRepositoryProvider(2).future);

    await testDb.container.read(shelfRepositoryProvider(2).notifier).updateShelfName('My Shelf');

    expect(testDb.container.read(shelfRepositoryProvider(2)).value?.name, 'My Shelf');
    final rows = await testDb.db.query(table: 'shelves', where: 'rowid = ?', whereArgs: [2]);
    expect(rows.single['name'], 'My Shelf');
  });

  test('updateShelfSize persists the new size', () async {
    keepAlive(testDb.container, shelfRepositoryProvider(2));
    await testDb.container.read(shelfRepositoryProvider(2).future);

    await testDb.container.read(shelfRepositoryProvider(2).notifier).updateShelfSize(42);

    expect(testDb.container.read(shelfRepositoryProvider(2)).value?.size, 42);
    final rows = await testDb.db.query(table: 'shelves', where: 'rowid = ?', whereArgs: [2]);
    expect(rows.single['size'], 42);
  });

  test('updateShelfType switches the collection type and query', () async {
    keepAlive(testDb.container, shelfRepositoryProvider(2));
    await testDb.container.read(shelfRepositoryProvider(2).future);

    await testDb.container.read(shelfRepositoryProvider(2).notifier).updateShelfType(CollectionType.TAG);

    final shelf = testDb.container.read(shelfRepositoryProvider(2)).value;
    expect(shelf?.type, CollectionType.TAG);

    final rows = await testDb.db.query(table: 'shelves', where: 'rowid = ?', whereArgs: [2]);
    expect(rows.single['type'], CollectionType.TAG.index);
  });

  test('updateShelfToSeries converts the shelf to a named SERIES collection', () async {
    keepAlive(testDb.container, shelfRepositoryProvider(2));
    await testDb.container.read(shelfRepositoryProvider(2).future);

    await testDb.container.read(shelfRepositoryProvider(2).notifier).updateShelfToSeries('Dresden Files, The');

    final shelf = testDb.container.read(shelfRepositoryProvider(2)).value;
    expect(shelf?.name, 'Dresden Files, The');
    expect(shelf?.type, CollectionType.SERIES);
    expect(shelf?.collection.queryArgs, ['Dresden Files, The']);
  });
}
