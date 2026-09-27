import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/models/collection.dart';
import 'package:paladin/models/series.dart';
import 'package:paladin/models/tag.dart';
import 'package:paladin/models/uuid.dart';
import 'package:paladin/repositories/collection_list_repository.dart';

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

  test('AUTHOR collection lists matching authors with their book counts', () async {
    await testDb.db.insertBook(Book(
      uuid: 'uuid-1',
      authors: const [Author(name: 'Butcher, Jim')],
      description: '',
      lastModified: 0,
      rating: 0,
      readStatus: false,
      tags: const [],
      title: 'Title 1',
    ));
    await testDb.db.insertBook(Book(
      uuid: 'uuid-2',
      authors: const [Author(name: 'Butcher, Jim')],
      description: '',
      lastModified: 0,
      rating: 0,
      readStatus: false,
      tags: const [],
      title: 'Title 2',
    ));

    final collection = Collection(type: CollectionType.AUTHOR, query: Author.authorsQuery, queryArgs: const ['%']);
    keepAlive(testDb.container, collectionListRepositoryProvider(collection));

    final results = await testDb.container.read(collectionListRepositoryProvider(collection).future);
    expect(results, hasLength(1));
    expect((results.single as Author).name, 'Butcher, Jim');
    expect((results.single as Author).count, 2);
  });

  test('BOOK collection lists matching uuids', () async {
    await testDb.db.insertBook(Book(
      uuid: 'uuid-1',
      authors: const [Author(name: 'Author')],
      description: '',
      lastModified: 0,
      rating: 0,
      readStatus: false,
      tags: const [],
      title: 'Brief Cases',
    ));

    final collection = Collection(type: CollectionType.BOOK, query: Uuid.uuidQuery, queryArgs: const ['%']);
    keepAlive(testDb.container, collectionListRepositoryProvider(collection));

    final results = await testDb.container.read(collectionListRepositoryProvider(collection).future);
    expect(results, hasLength(1));
    expect((results.single as Uuid).uuid, 'uuid-1');
  });

  test('SERIES collection lists matching series with their book counts', () async {
    await testDb.db.insertBook(Book(
      uuid: 'uuid-1',
      authors: const [Author(name: 'Author')],
      description: '',
      lastModified: 0,
      rating: 0,
      readStatus: false,
      series: const Series(series: 'Dresden Files, The', queryArgs: ['Dresden Files, The']),
      tags: const [],
      title: 'Title 1',
    ));

    final collection = Collection(type: CollectionType.SERIES, query: Series.seriesQuery, queryArgs: const ['%']);
    keepAlive(testDb.container, collectionListRepositoryProvider(collection));

    final results = await testDb.container.read(collectionListRepositoryProvider(collection).future);
    expect(results, hasLength(1));
    expect((results.single as Series).series, 'Dresden Files, The');
    expect((results.single as Series).count, 1);
  });

  test('TAG collection lists matching tags with their book counts', () async {
    await testDb.db.insertBook(Book(
      uuid: 'uuid-1',
      authors: const [Author(name: 'Author')],
      description: '',
      lastModified: 0,
      rating: 0,
      readStatus: false,
      tags: const [Tag(tag: 'Mystery')],
      title: 'Title 1',
    ));

    final collection = Collection(type: CollectionType.TAG, query: Tag.tagsQuery, queryArgs: const ['%']);
    keepAlive(testDb.container, collectionListRepositoryProvider(collection));

    final results = await testDb.container.read(collectionListRepositoryProvider(collection).future);
    expect(results, hasLength(1));
    expect((results.single as Tag).tag, 'Mystery');
  });

  test('returns an empty list when nothing matches the query args', () async {
    await testDb.db.insertBook(Book(
      uuid: 'uuid-1',
      authors: const [Author(name: 'Butcher, Jim')],
      description: '',
      lastModified: 0,
      rating: 0,
      readStatus: false,
      tags: const [],
      title: 'Title 1',
    ));

    final collection = Collection(type: CollectionType.AUTHOR, query: Author.authorsQuery, queryArgs: const ['Nobody']);
    keepAlive(testDb.container, collectionListRepositoryProvider(collection));

    final results = await testDb.container.read(collectionListRepositoryProvider(collection).future);
    expect(results, isEmpty);
  });
}
