import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/models/collection.dart';
import 'package:paladin/models/shelf.dart';
import 'package:paladin/repositories/shelf_books_repository.dart';

import '../helpers/keep_alive.dart';
import '../helpers/test_database.dart';

Book _book(String uuid, {int lastRead = 0, bool readStatus = false}) => Book(
      uuid: uuid,
      authors: const [Author(name: 'Author')],
      description: '',
      lastModified: 0,
      lastRead: lastRead,
      rating: 0,
      readStatus: readStatus,
      tags: const [],
      title: 'Title $uuid',
    );

void main() {
  late TestDatabase testDb;

  setUp(() async {
    testDb = await TestDatabase.open();
  });

  tearDown(() {
    testDb.dispose();
  });

  test('returns no uuids for an empty database', () async {
    final collection = Collection(type: CollectionType.CURRENT, query: Shelf.shelfQuery[CollectionType.CURRENT]!, queryArgs: const [10]);
    keepAlive(testDb.container, shelfBooksRepositoryProvider(collection));

    final uuids = await testDb.container.read(shelfBooksRepositoryProvider(collection).future);
    expect(uuids, isEmpty);
  });

  test('CURRENT collection returns books being read, most recently read first', () async {
    await testDb.db.insertBook(_book('uuid-old', lastRead: 100));
    await testDb.db.insertBook(_book('uuid-new', lastRead: 300));
    await testDb.db.insertBook(_book('uuid-unread'));

    final collection = Collection(type: CollectionType.CURRENT, query: Shelf.shelfQuery[CollectionType.CURRENT]!, queryArgs: const [10]);
    keepAlive(testDb.container, shelfBooksRepositoryProvider(collection));

    final uuids = await testDb.container.read(shelfBooksRepositoryProvider(collection).future);
    expect(uuids, ['uuid-new', 'uuid-old']);
  });

  test('RANDOM collection excludes books that are read or already being read', () async {
    await testDb.db.insertBook(_book('uuid-unread'));
    await testDb.db.insertBook(_book('uuid-reading', lastRead: 100));
    await testDb.db.insertBook(_book('uuid-read', readStatus: true));

    final collection = Collection(type: CollectionType.RANDOM, query: Shelf.shelfQuery[CollectionType.RANDOM]!, queryArgs: const [10]);
    keepAlive(testDb.container, shelfBooksRepositoryProvider(collection));

    final uuids = await testDb.container.read(shelfBooksRepositoryProvider(collection).future);
    expect(uuids, ['uuid-unread']);
  });

  test('updateCollection re-queries and updates state', () async {
    final collection = Collection(type: CollectionType.CURRENT, query: Shelf.shelfQuery[CollectionType.CURRENT]!, queryArgs: const [10]);
    keepAlive(testDb.container, shelfBooksRepositoryProvider(collection));
    await testDb.container.read(shelfBooksRepositoryProvider(collection).future);

    await testDb.db.insertBook(_book('uuid-1', lastRead: 100));
    testDb.container.read(shelfBooksRepositoryProvider(collection).notifier).updateCollection(collection);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(testDb.container.read(shelfBooksRepositoryProvider(collection)).value, ['uuid-1']);
  });
}
