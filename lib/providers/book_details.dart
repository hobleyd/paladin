import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../models/book.dart';
import '../providers/currently_reading_book.dart';
import '../repositories/books_repository.dart';
import '../repositories/app_settings_repository.dart';
import '../repositories/shelf_repository.dart';
import '../repositories/shelves_repository.dart';

part 'book_details.g.dart';

@riverpod
class BookDetails extends _$BookDetails {
  static const _inkwormChannel = MethodChannel('au.com.sharpblue.paladin/inkworm');

  @override
  Book? build(String uuid) {
    getBook();
    return null;
  }

  Future<void> getBook() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);

    List<Map<String, dynamic>> results = await libraryDb.query(
        table: "books",
        columns: ["uuid", "mimeType", "added", "description", "lastModified", "lastRead", "rating", "readStatus", "series", "seriesIndex", "title"],
        where: "uuid == ?",
        whereArgs: [uuid],
        orderBy: "lastRead ASC");

    if (!ref.mounted) return;
    final book = await Book.fromMap(libraryDb, results.first);
    if (!ref.mounted) return;
    state = book;
  }

  Future<void> readBook() async {
    updateLastReadDate();

    final appSettings = ref.read(appSettingsRepositoryProvider).value;
    if (appSettings?.autoUpdateShelf == true && state?.series != null && state!.series!.series.isNotEmpty) {
      ref.read(shelvesRepositoryProvider.notifier).updateShelfForSeries(state!.series!.series);
    }

    if (Platform.isMacOS) {
      Process.run('open', ['-a', 'Inkworm', await state!.path]);
    } else if (Platform.isIOS && await _openInInkworm(await state!.path)) {
      return;
    } else {
      OpenFilex.open(await state!.path, type: state!.mimeType);
    }
  }

  // iOS: hand the book straight to Inkworm over its inkworm:// URL scheme.
  // False when Inkworm isn't installed, so the caller shows the "Open in…" sheet.
  Future<bool> _openInInkworm(String path) async {
    try {
      return await _inkwormChannel.invokeMethod<bool>('open', path) ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future setRating(int newRating) async {
    int lastModified = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    var libraryDb = ref.read(libraryDBProvider.notifier);
    libraryDb.updateTable(table: BooksRepository.booksTable, values: {'rating': newRating, 'lastModified': lastModified}, where: 'uuid = ?', whereArgs: [state!.uuid]);

    state = state!.copyBookWith(rating: newRating);
  }

  Future<void> updateBook(Book updatedBook) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    libraryDb.insertBook(updatedBook);
    state = updatedBook;

    return;
  }

  Future updateLastReadDate() async {
    int lastRead = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.updateTable(table: 'books', values: {'lastRead': lastRead, 'lastModified': lastRead, 'readStatus': 1}, where: 'uuid = ?', whereArgs: [state!.uuid]);

    // Ensure Currently Reading Shelf is updated.
    ref.read(shelfRepositoryProvider(1).notifier).updateShelf();
    ref.read(currentlyReadingBookProvider.notifier).updateCurrentlyReading();
    state = state!.copyBookWith(lastRead: lastRead, readStatus: true);
  }
}
