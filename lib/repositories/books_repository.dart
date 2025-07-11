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


  Future<void> updateBooksCount() async {
    state = AsyncValue.data(await _getBooksCount());
  }

  Future setRating(Book book, int newRating) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    libraryDb.updateTable(table: booksTable, values: { 'rating' : newRating }, where: 'uuid = ?', whereArgs: [book.uuid]);
  }

  Future updateBookLastReadDate(Book book) async {
    int lastRead = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    int lastModified = book.lastRead!;

    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.updateTable(table: 'books', values: { 'lastRead' : lastRead, 'lastModified' : lastModified }, where: 'uuid = ?', whereArgs: [ book.uuid]);

    // TODO: Update Currently Reading Shelf!
    //await _getCurrentlyReading(_paladin, Collection(type: CollectionType.CURRENT));
  }

  Future<int> _getBooksCount() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    return await libraryDb.getCount(booksTable);
  }
}