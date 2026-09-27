import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/models/uuid.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabase testDb;

  const book = Book(
    uuid: 'uuid-1',
    authors: [Author(name: 'Butcher, Jim')],
    description: '',
    lastModified: 0,
    rating: 0,
    readStatus: false,
    tags: [],
    title: 'Brief Cases',
  );

  setUp(() async {
    testDb = await TestDatabase.open();
  });

  tearDown(() {
    testDb.dispose();
  });

  test('creates the initial "Currently Reading" and "Random Shelf" shelves on first run', () async {
    final shelves = await testDb.db.query(table: 'shelves', orderBy: 'rowid asc');

    expect(shelves, hasLength(2));
    expect(shelves[0]['name'], 'Currently Reading');
    expect(shelves[1]['name'], 'Random Shelf');
  });

  test('insertBook is idempotent (conflict replace) on repeat inserts of the same uuid', () async {
    await testDb.db.insertBook(book);
    await testDb.db.insertBook(book.copyBookWith(rating: 5));

    final rows = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['uuid-1']);
    expect(rows, hasLength(1));
    expect(rows.single['rating'], 5);
  });

  test('insertBook reuses an existing author row instead of duplicating it', () async {
    await testDb.db.insertBook(book);
    await testDb.db.insertBook(book.copyBookWith(uuid: 'uuid-2'));

    final authors = await testDb.db.query(table: 'authors', where: 'name = ?', whereArgs: ['Butcher, Jim']);
    expect(authors, hasLength(1));
  });

  test('getCount reflects inserts and removeBook', () async {
    expect(await testDb.db.getCount('books'), 0);

    await testDb.db.insertBook(book);
    expect(await testDb.db.getCount('books'), 1);

    await testDb.db.removeBook(const Uuid(uuid: 'uuid-1'));
    expect(await testDb.db.getCount('books'), 0);
  });

  test('findLocalBooksNotInCalibre and findRemoteBooksNotInDb diff against an uploaded uuid set', () async {
    await testDb.db.insertBook(book);
    await testDb.db.insertBook(book.copyBookWith(uuid: 'uuid-2'));

    // Calibre only knows about uuid-2 and a book we don't have locally yet.
    await testDb.db.uploadTemporaryUuids(const [Uuid(uuid: 'uuid-2'), Uuid(uuid: 'uuid-3')]);

    final localOnly = await testDb.db.findLocalBooksNotInCalibre();
    expect(localOnly.map((u) => u.uuid), ['uuid-1']);

    final remoteOnly = await testDb.db.findRemoteBooksNotInDb();
    expect(remoteOnly.map((u) => u.uuid), ['uuid-3']);
  });

  test('getLastModified and getLastRead return 0 for an unknown book', () async {
    expect(await testDb.db.getLastModified(book), 0);
    expect(await testDb.db.getLastRead(book), 0);
  });

  test('updateTable updates matching rows only', () async {
    await testDb.db.insertBook(book);
    await testDb.db.insertBook(book.copyBookWith(uuid: 'uuid-2'));

    await testDb.db.updateTable(table: 'books', values: {'rating': 9}, where: 'uuid = ?', whereArgs: ['uuid-1']);

    final updated = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['uuid-1']);
    final untouched = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['uuid-2']);
    expect(updated.single['rating'], 9);
    expect(untouched.single['rating'], 0);
  });
}
