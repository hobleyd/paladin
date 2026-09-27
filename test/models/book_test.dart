import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/models/series.dart';
import 'package:paladin/models/tag.dart';

import '../helpers/test_database.dart';

void main() {
  group('toMap / copyBookWith (no database required)', () {
    const book = Book(
      uuid: 'uuid-1',
      authors: [Author(name: 'Butcher, Jim')],
      description: 'A description',
      lastModified: 1000,
      lastRead: 0,
      rating: 3,
      readStatus: false,
      tags: [Tag(tag: 'Fantasy')],
      title: 'Brief Cases',
    );

    test('toMap encodes readStatus as an integer', () {
      final map = book.toMap();
      expect(map['readStatus'], 0);
      expect(map['uuid'], 'uuid-1');
      expect(map['title'], 'Brief Cases');
      expect(map['mimeType'], 'application/epub+zip');
    });

    test('toMap encodes a read book as 1', () {
      final map = book.copyBookWith(readStatus: true).toMap();
      expect(map['readStatus'], 1);
    });

    test('copyBookWith only overrides the fields it is given', () {
      final updated = book.copyBookWith(rating: 5);

      expect(updated.rating, 5);
      expect(updated.uuid, book.uuid);
      expect(updated.readStatus, book.readStatus);
      expect(updated.title, book.title);
    });

    test('copyBookWith(readStatus: true) flips readStatus without touching other fields', () {
      final updated = book.copyBookWith(readStatus: true);

      expect(updated.readStatus, isTrue);
      expect(updated.lastRead, book.lastRead);
      expect(updated.rating, book.rating);
    });
  });

  group('fromMap round trip (real database)', () {
    late TestDatabase testDb;

    setUp(() async {
      testDb = await TestDatabase.open();
    });

    tearDown(() {
      testDb.dispose();
    });

    test('insertBook then fromMap reconstructs authors, tags and series', () async {
      const original = Book(
        uuid: 'uuid-2',
        authors: [Author(name: 'Butcher, Jim'), Author(name: 'Cole, August')],
        description: 'A description',
        lastModified: 2000,
        lastRead: 0,
        rating: 4,
        readStatus: true,
        series: Series(series: 'Dresden Files, The', queryArgs: ['Dresden Files, The']),
        seriesIndex: 15.5,
        tags: [Tag(tag: 'Mystery'), Tag(tag: 'Supernatural')],
        title: 'Brief Cases',
      );

      await testDb.db.insertBook(original);

      final rows = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['uuid-2']);
      expect(rows, hasLength(1));

      final roundTripped = await Book.fromMap(testDb.db, rows.single);

      expect(roundTripped.uuid, original.uuid);
      expect(roundTripped.title, original.title);
      expect(roundTripped.readStatus, isTrue);
      expect(roundTripped.rating, original.rating);
      expect(roundTripped.seriesIndex, original.seriesIndex);
      expect(roundTripped.authors.map((a) => a.name), containsAll(['Butcher, Jim', 'Cole, August']));
      expect(roundTripped.tags.map((t) => t.tag), containsAll(['Mystery', 'Supernatural']));
      expect(roundTripped.series?.series, 'Dresden Files, The');
    });

    test('readStatus survives the int/bool conversion round trip', () async {
      const unread = Book(
        uuid: 'uuid-3',
        authors: [Author(name: 'Author')],
        description: '',
        lastModified: 0,
        rating: 0,
        readStatus: false,
        tags: [],
        title: 'Unread Book',
      );
      await testDb.db.insertBook(unread);

      final rows = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['uuid-3']);
      expect(rows.single['readStatus'], 0);

      final roundTripped = await Book.fromMap(testDb.db, rows.single);
      expect(roundTripped.readStatus, isFalse);
    });
  });
}
