import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:paladin/providers/currently_reading_book.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/library_db.dart';
import '../models/book.dart';
import '../repositories/books_repository.dart';
import '../repositories/shelf_repository.dart';

part 'book_provider.g.dart';

@riverpod
class BookProvider extends _$BookProvider {
  @override
  Book? build(String uuid) {
    return null;
  }

  Future readBook() async {
    updateLastReadDate();

    if (Platform.isAndroid || Platform.isIOS) {
      OpenFilex.open(await state!.path, type: state!.mimeType);
    } else {
      launchUrl(Uri.file(await state!.path));
    }
  }

  void setBook(Book book) {
    state = book;
  }

  Future setRating(int newRating) async {
    int lastModified = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    var libraryDb = ref.read(libraryDBProvider.notifier);
    libraryDb.updateTable(table: BooksRepository.booksTable, values: {'rating': newRating, 'lastModified': lastModified}, where: 'uuid = ?', whereArgs: [state!.uuid]);

    state = state!.copyBookWith(rating: newRating);
  }

  Future updateLastReadDate() async {
    int lastRead = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.updateTable(table: 'books', values: {'lastRead': lastRead, 'readStatus': 1}, where: 'uuid = ?', whereArgs: [state!.uuid]);

    // Ensure Currently Reading Shelf is updated.
    ref.read(shelfRepositoryProvider(1).notifier).updateShelf();
    ref.read(currentlyReadingBookProvider.notifier).updateCurrentReading();
    state = state!.copyBookWith(lastRead: lastRead);
  }
}
