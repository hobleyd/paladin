import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../interfaces/database_notifier.dart';
import '../models/book.dart';
import '../providers/calibre_ws.dart';

part 'books_repository.g.dart';

@riverpod
class BooksRepository extends _$BooksRepository implements DatabaseNotifier {
  static const String booksTable = 'books';

  static const String books = '''
        create table if not exists $booksTable(
          uuid text primary key,
          description text,
          mimeType text not null,
          added integer not null,
          lastModified integer,
          lastRead integer,
          rating integer,
          readStatus integer,
          series integer, 
          seriesIndex real,
          title text not null,
          unique(uuid) on conflict replace);
          ''';

  static const String indexBooks = 'create index books_uuid_idx on books(uuid);';

  @override
  Future<int> build() async {
    ref.read(calibreWSProvider.notifier).addUpdateNotifier(this);
    return _getBooksCount();
  }

  Future<List<Book>> getReadingList(int lastConnected) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    List<Map<String, dynamic>> results = await libraryDb.query(
        table: "books",
        columns: ["uuid", "mimeType", "added", "lastModified", "lastRead", "rating", "readStatus", "series", "seriesIndex", "title"],
        where: "lastRead > ?",
        whereArgs: [lastConnected],
        orderBy: "lastRead ASC");

    return Future.wait(results.map((book) => Book.fromMap(libraryDb, book)).toList());
  }

  @override
  Future<void> updateStateFromDb() async {
    state = AsyncValue.data(await _getBooksCount());
  }

  Future<int> _getBooksCount() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    return await libraryDb.getCount(booksTable);
  }
}