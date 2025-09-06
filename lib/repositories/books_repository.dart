import 'package:paladin/providers/currently_reading_book.dart';
import 'package:paladin/repositories/shelf_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../models/book.dart';

part 'books_repository.g.dart';

@riverpod
class BooksRepository extends _$BooksRepository {
  static const String booksTable = 'books';

  static const String books = '''
        create table if not exists $booksTable(
          uuid text primary key,
          description text,
          path text not null,
          mimeType text not null,
          added integer not null,
          lastModified integer,
          lastRead integer,
          rating integer,
          readStatus integer,
          series integer, 
          seriesIndex real,
          title text not null,
          unique(uuid) on conflict replace,
          foreign key(series) references series(id));
          ''';

  static const String indexBooks = 'create index books_uuid_idx on books(uuid);';

  @override
  Future<int> build() async {
    return _getBooksCount();
  }

  Future<List<Book>> getReadingList(int lastConnected) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    List<Map<String, dynamic>> results = await libraryDb.query(
        table: "books",
        columns: ["uuid", "path", "mimeType", "added", "lastModified", "lastRead", "rating", "readStatus", "series", "seriesIndex", "title"],
        where: "lastRead > ?",
        whereArgs: [lastConnected],
        orderBy: "lastRead ASC");

    return Future.wait(results.map((book) => Book.fromMap(libraryDb, book)).toList());
  }

  Future setRating(Book book, int newRating) async {
    int lastModified = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    var libraryDb = ref.read(libraryDBProvider.notifier);
    libraryDb.updateTable(table: booksTable, values: { 'rating' : newRating, 'lastModified' : lastModified }, where: 'uuid = ?', whereArgs: [book.uuid]);
  }

  Future<void> updateBooksCount() async {
    state = AsyncValue.data(await _getBooksCount());
  }

  Future<int> _getBooksCount() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    return await libraryDb.getCount(booksTable);
  }
}