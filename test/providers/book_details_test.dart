import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/providers/book_details.dart';
import 'package:paladin/providers/currently_reading_book.dart';
import 'package:paladin/repositories/shelf_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabase testDb;

  const book = Book(
    uuid: 'book-1',
    authors: [Author(name: 'Butcher, Jim')],
    description: '',
    lastModified: 0,
    rating: 0,
    readStatus: false,
    tags: [],
    title: 'Brief Cases',
  );

  // updateLastReadDate() also touches the "Currently Reading" shelf (id 1,
  // created by LibraryDB on first run) and currentlyReadingBookProvider.
  // All three providers are autoDispose, so a bare `.read()` on them would
  // dispose again immediately; keep them alive like a watching widget would.
  void keepAlive() {
    addTearDown(testDb.container.listen(bookDetailsProvider('book-1'), (_, _) {}).close);
    addTearDown(testDb.container.listen(shelfRepositoryProvider(1), (_, _) {}).close);
    addTearDown(testDb.container.listen(currentlyReadingBookProvider, (_, _) {}).close);
  }

  // updateLastReadDate() kicks off the shelf/currently-reading updates
  // without awaiting them; give those fire-and-forget calls a chance to
  // finish their (real, isolate-backed) DB round trips before the test's
  // container-disposing tearDown runs.
  Future<void> settle() async {
    for (int i = 0; i < 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  setUp(() async {
    testDb = await TestDatabase.open();
    await testDb.db.insertBook(book);
  });

  tearDown(() {
    testDb.dispose();
  });

  test('updateLastReadDate marks the book read in memory, not just in the database', () async {
    keepAlive();

    final notifier = testDb.container.read(bookDetailsProvider('book-1').notifier);
    await notifier.getBook();
    expect(notifier.state?.readStatus, isFalse);

    await notifier.updateLastReadDate();
    await settle();

    // Regression test: updateLastReadDate() used to rebuild in-memory state
    // via `copyBookWith(lastRead: lastRead)` without also passing
    // `readStatus: true`, so the unread star kept showing until the app
    // restarted and re-read the book from the database.
    expect(notifier.state?.readStatus, isTrue);

    final rows = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['book-1']);
    expect(rows.single['readStatus'], 1);
  });

  test('updateLastReadDate persists lastRead alongside readStatus', () async {
    keepAlive();

    final notifier = testDb.container.read(bookDetailsProvider('book-1').notifier);
    await notifier.getBook();

    await notifier.updateLastReadDate();
    await settle();

    expect(notifier.state?.lastRead, greaterThan(0));

    final rows = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['book-1']);
    expect(rows.single['lastRead'], notifier.state?.lastRead);
  });
}
