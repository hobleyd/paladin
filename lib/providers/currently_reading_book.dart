import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../models/book.dart';

part 'currently_reading_book.g.dart';

@riverpod
class CurrentlyReadingBook extends _$CurrentlyReadingBook {
  @override
  Future<Book?> build() {
    return _getCurrentlyReading();
  }

  Future<void> updateCurrentlyReading() async {
    state = AsyncValue.data(await _getCurrentlyReading());
  }

  Future<Book?> _getCurrentlyReading() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    List<Map<String, dynamic>> results = await libraryDb.query(
        table: "books",
        columns: ["uuid", "mimeType", "added", "description", "lastModified", "lastRead", "rating", "readStatus", "series", "seriesIndex", "title"],
        where: "lastRead > 0",
        orderBy: "lastRead DESC",
        limit: 1);

    if (results.length == 1) {
      Book book = await Book.fromMap(libraryDb, results.first);

      return book;
    }
    return null;
  }
}