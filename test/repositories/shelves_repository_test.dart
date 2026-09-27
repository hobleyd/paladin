import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/models/collection.dart';
import 'package:paladin/repositories/shelf_repository.dart';
import 'package:paladin/repositories/shelves_repository.dart';

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

  test('build lists the two shelves LibraryDB creates on first run', () async {
    keepAlive(testDb.container, shelvesRepositoryProvider);
    final shelfIds = await testDb.container.read(shelvesRepositoryProvider.future);

    expect(shelfIds, [1, 2]);
  });

  test('addShelf appends a new shelf id and persists it once saved', () async {
    keepAlive(testDb.container, shelvesRepositoryProvider);
    keepAlive(testDb.container, shelfRepositoryProvider(3));
    await testDb.container.read(shelvesRepositoryProvider.future);

    final notifier = testDb.container.read(shelvesRepositoryProvider.notifier);
    await notifier.addShelf();

    expect(testDb.container.read(shelvesRepositoryProvider).value, [1, 2, 3]);

    // addShelf() persists the new shelf's row without awaiting it; give that
    // a moment to finish before tearDown disposes the (real, isolate-backed)
    // database out from under it.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final rows = await testDb.db.query(table: 'shelves', where: 'rowid = ?', whereArgs: [3]);
    expect(rows, hasLength(1));
  });

  test('removeShelf drops the last shelf id and deletes its row', () async {
    keepAlive(testDb.container, shelvesRepositoryProvider);
    await testDb.container.read(shelvesRepositoryProvider.future);

    final notifier = testDb.container.read(shelvesRepositoryProvider.notifier);
    await notifier.removeShelf();

    expect(testDb.container.read(shelvesRepositoryProvider).value, [1]);
    final rows = await testDb.db.query(table: 'shelves', where: 'rowid = ?', whereArgs: [2]);
    expect(rows, isEmpty);
  });

  test('updateShelfForSeries converts the first non-CURRENT/RANDOM shelf to the given series', () async {
    keepAlive(testDb.container, shelvesRepositoryProvider);
    keepAlive(testDb.container, shelfRepositoryProvider(2));
    await testDb.container.read(shelvesRepositoryProvider.future);
    await testDb.container.read(shelfRepositoryProvider(2).future);

    // Shelf 2 ("Random Shelf") starts out as RANDOM, which is skipped by
    // updateShelfForSeries; retype it so it becomes an eligible candidate.
    await testDb.container.read(shelfRepositoryProvider(2).notifier).updateShelfType(CollectionType.TAG);

    await testDb.db.insertBook(Book(
      uuid: 'uuid-1',
      authors: const [Author(name: 'Author')],
      description: '',
      lastModified: 0,
      rating: 0,
      readStatus: false,
      tags: const [],
      title: 'Title',
    ));

    await testDb.container.read(shelvesRepositoryProvider.notifier).updateShelfForSeries('Dresden Files, The');

    final shelf = testDb.container.read(shelfRepositoryProvider(2)).value;
    expect(shelf?.type, CollectionType.SERIES);
    expect(shelf?.name, 'Dresden Files, The');
  });

  test('updateShelfForSeries is a no-op when every shelf is CURRENT or RANDOM', () async {
    keepAlive(testDb.container, shelvesRepositoryProvider);
    keepAlive(testDb.container, shelfRepositoryProvider(1));
    keepAlive(testDb.container, shelfRepositoryProvider(2));
    await testDb.container.read(shelvesRepositoryProvider.future);
    await testDb.container.read(shelfRepositoryProvider(1).future);
    await testDb.container.read(shelfRepositoryProvider(2).future);

    await testDb.container.read(shelvesRepositoryProvider.notifier).updateShelfForSeries('Dresden Files, The');

    expect(testDb.container.read(shelfRepositoryProvider(1)).value?.type, CollectionType.CURRENT);
    expect(testDb.container.read(shelfRepositoryProvider(2)).value?.type, CollectionType.RANDOM);
  });
}
