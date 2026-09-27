// AuthorsRepository, SeriesRepository and TagsRepository are all the same
// shape: an autoDispose count of rows in one table, refreshed on demand via
// updateStateFromDb(). Covered together rather than in three near-identical
// files.
import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/models/series.dart';
import 'package:paladin/models/tag.dart';
import 'package:paladin/repositories/authors_repository.dart';
import 'package:paladin/repositories/series_repository.dart';
import 'package:paladin/repositories/tags_repository.dart';

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

  Book book(String uuid, {List<Author> authors = const [], Series? series, List<Tag> tags = const []}) => Book(
        uuid: uuid,
        authors: authors,
        description: '',
        lastModified: 0,
        rating: 0,
        readStatus: false,
        series: series,
        tags: tags,
        title: 'Title $uuid',
      );

  group('AuthorsRepository', () {
    test('starts at 0 and reflects inserted authors after updateStateFromDb', () async {
      keepAlive(testDb.container, authorsRepositoryProvider);
      expect(await testDb.container.read(authorsRepositoryProvider.future), 0);

      await testDb.db.insertBook(book('uuid-1', authors: const [Author(name: 'Butcher, Jim'), Author(name: 'Cole, August')]));
      await testDb.container.read(authorsRepositoryProvider.notifier).updateStateFromDb();

      expect(testDb.container.read(authorsRepositoryProvider).value, 2);
    });

    test('does not double-count an author shared by two books', () async {
      keepAlive(testDb.container, authorsRepositoryProvider);
      await testDb.db.insertBook(book('uuid-1', authors: const [Author(name: 'Butcher, Jim')]));
      await testDb.db.insertBook(book('uuid-2', authors: const [Author(name: 'Butcher, Jim')]));

      await testDb.container.read(authorsRepositoryProvider.notifier).updateStateFromDb();

      expect(testDb.container.read(authorsRepositoryProvider).value, 1);
    });
  });

  group('SeriesRepository', () {
    test('starts at 0 and reflects an inserted series after updateStateFromDb', () async {
      keepAlive(testDb.container, seriesRepositoryProvider);
      expect(await testDb.container.read(seriesRepositoryProvider.future), 0);

      await testDb.db.insertBook(book('uuid-1', series: const Series(series: 'Dresden Files, The', queryArgs: ['Dresden Files, The'])));
      await testDb.container.read(seriesRepositoryProvider.notifier).updateStateFromDb();

      expect(testDb.container.read(seriesRepositoryProvider).value, 1);
    });
  });

  group('TagsRepository', () {
    test('starts at 0 and reflects inserted tags after updateStateFromDb', () async {
      keepAlive(testDb.container, tagsRepositoryProvider);
      expect(await testDb.container.read(tagsRepositoryProvider.future), 0);

      await testDb.db.insertBook(book('uuid-1', tags: const [Tag(tag: 'Mystery'), Tag(tag: 'Supernatural')]));
      await testDb.container.read(tagsRepositoryProvider.notifier).updateStateFromDb();

      expect(testDb.container.read(tagsRepositoryProvider).value, 2);
    });

    test('does not double-count a tag shared by two books', () async {
      keepAlive(testDb.container, tagsRepositoryProvider);
      await testDb.db.insertBook(book('uuid-1', tags: const [Tag(tag: 'Mystery')]));
      await testDb.db.insertBook(book('uuid-2', tags: const [Tag(tag: 'Mystery')]));

      await testDb.container.read(tagsRepositoryProvider.notifier).updateStateFromDb();

      expect(testDb.container.read(tagsRepositoryProvider).value, 1);
    });
  });
}
