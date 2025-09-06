import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:paladin/database/library_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/book.dart';
import '../repositories/shelf_repository.dart';

part 'currently_reading_book.g.dart';

@riverpod
class CurrentlyReadingBook extends _$CurrentlyReadingBook {
  @override
  Future<Book?> build() {
    return _getCurrentlyReading();
  }

  Future updateLastReadDate(Book book) async {
    int lastRead = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    int lastModified = book.lastRead!;

    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.updateTable(table: 'books', values: { 'lastRead' : lastRead, 'lastModified' : lastModified, 'readStatus' : 1}, where: 'uuid = ?', whereArgs: [ book.uuid]);

    // Ensure Currently Reading Shelf is updated.
    ref.read(shelfRepositoryProvider(1).notifier).updateShelf();
    state = AsyncValue.data(book);
  }

  Future readBook(Book book) async {
    updateLastReadDate(book);

    if (Platform.isAndroid || Platform.isIOS) {
      OpenFilex.open(book.path, type: book.mimeType);
    } else {
      launchUrl(Uri.file(book.path));
    }
  }

  Future<Book?> _getCurrentlyReading() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    List<Map<String, dynamic>> results = await libraryDb.query(
        table: "books",
        columns: ["uuid", "path", "mimeType", "added", "description", "lastModified", "lastRead", "rating", "readStatus", "series", "seriesIndex", "title"],
        where: "lastRead > 0",
        orderBy: "lastRead DESC",
        limit: 1);

    return results.length == 1
        ? Book.fromMap(libraryDb, results.first)
        : null;
  }
}