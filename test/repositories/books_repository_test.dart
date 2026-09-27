import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/repositories/books_repository.dart';

import '../helpers/keep_alive.dart';
import '../helpers/test_database.dart';

Book _book(String uuid, {int lastRead = 0}) => Book(
      uuid: uuid,
      authors: const [Author(name: 'Author')],
      description: '',
      lastModified: 0,
      lastRead: lastRead,
      rating: 0,
      readStatus: false,
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

  test('starts at 0 for an empty database', () async {
    keepAlive(testDb.container, booksRepositoryProvider);
    expect(await testDb.container.read(booksRepositoryProvider.future), 0);
  });

  test('updateStateFromDb picks up books inserted directly against the database', () async {
    keepAlive(testDb.container, booksRepositoryProvider);
    await testDb.container.read(booksRepositoryProvider.future);

    await testDb.db.insertBook(_book('uuid-1'));
    await testDb.db.insertBook(_book('uuid-2'));

    final notifier = testDb.container.read(booksRepositoryProvider.notifier);
    await notifier.updateStateFromDb();

    expect(testDb.container.read(booksRepositoryProvider).value, 2);
  });

  test('getReadingList returns books read after the given time, oldest read first', () async {
    keepAlive(testDb.container, booksRepositoryProvider);
    await testDb.db.insertBook(_book('uuid-old', lastRead: 100));
    await testDb.db.insertBook(_book('uuid-new', lastRead: 300));
    await testDb.db.insertBook(_book('uuid-never-read', lastRead: 0));

    final notifier = testDb.container.read(booksRepositoryProvider.notifier);
    final readingList = await notifier.getReadingList(50);

    expect(readingList.map((b) => b.uuid), ['uuid-old', 'uuid-new']);
  });

  test('getReadingList excludes books read before lastConnected', () async {
    keepAlive(testDb.container, booksRepositoryProvider);
    await testDb.db.insertBook(_book('uuid-old', lastRead: 100));
    await testDb.db.insertBook(_book('uuid-new', lastRead: 300));

    final notifier = testDb.container.read(booksRepositoryProvider.notifier);
    final readingList = await notifier.getReadingList(200);

    expect(readingList.map((b) => b.uuid), ['uuid-new']);
  });
}
