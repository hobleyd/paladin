import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http_status_code/http_status_code.dart';

import '../database/library_db.dart';
import '../models/book.dart';
import '../models/book_count.dart';
import '../models/calibre_sync_data.dart';
import '../models/json_book.dart';
import '../repositories/books_repository.dart';
import '../repositories/last_connected.dart';
import 'cached_cover.dart';
import 'calibre_book_provider.dart';
import 'calibre_dio.dart';
import 'status_provider.dart';

part 'calibre_ws.g.dart';

@Riverpod(keepAlive: true)
class CalibreWS extends _$CalibreWS {
  @override
  CalibreSyncData build() {
    return CalibreSyncData();
  }

  Future<void> setSyncFromEpoch(bool? syncFrom) async {
    if (syncFrom != null) {
      state = state.copyWith(syncFromEpoch: syncFrom);
    }

    return;
  }

  void stopSynchronisation() {
    state = state.copyWith(processing: false);
  }

  Future<void> synchroniseWithCalibre() async {
    var status = ref.read(statusProvider.notifier);

    state = state.copyWith(processing: true);
    status.addStatus('Initialising Sync...');

    //await _updateReadStatuses();
    await _getUpdatedBooks();

    ref.read(calibreLastConnectedDateProvider.notifier).setLastConnected();

    status.addStatus('Completed Synchronisation');
    state = state.copyWith(status: 'Completed Synchronisation', );
  }

  Future<void> _downloadBook(Book book) async {
    final file = File(book.path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    final response = ref.read(calibreDioProvider).getBook(book.uuid, 4096);
    final sink = file.openWrite();
    await for (final chunk in response) {
      sink.add(chunk);
    }
    await sink.flush();
    await sink.close();
    ref.read(cachedCoverProvider(book).notifier).cacheCover();
  }

  Future<void> _getUpdatedBooks() async {
    var status = ref.read(statusProvider.notifier);
    var calibre = ref.read(calibreDioProvider);
    int lastConnected = ref.read(calibreLastConnectedDateProvider.notifier).lastConnected;

    const int size = 100;
    BookCount bookCount = await calibre.getCount(lastConnected);
    status.addStatus('Received ${bookCount.count} Books in the batch.');

    int offset = 0;
    while (offset < bookCount.count) {
      await _getBooksWithOffset(offset, size, bookCount.count);
      offset += size;
    }
  }

  Future<void> _getBooksWithOffset(int offset, int size, int total) async {
    LibraryDB library = ref.read(libraryDBProvider.notifier);
    var calibre = ref.read(calibreDioProvider);
    var status = ref.read(statusProvider.notifier);

    status.addStatus('Syncing ${total < size ? total : size} books ($offset/$total)');

    List<JSONBook> books = await calibre.getBooks(ref.read(calibreLastConnectedDateProvider.notifier).lastConnected, offset, size);
    int index = offset;
    for (JSONBook element in books) {
      ref.read(calibreBookProvider(BooksType.processed).notifier).add(element);
      try {
        element.Tags = await calibre.getTags(element.UUID);

        Book calibreBook = await Book.fromJSON(element);
        // Only download the Book if something has changed since last time!
        if (calibreBook.lastModified > await library.getLastModified(calibreBook)) {
          status.addStatus('${calibreBook.title} ($index/$total) has changed; downloading...');
          await _downloadBook(calibreBook);
          await library.insertBook(calibreBook);
        }
      } catch (e) {
        ref.read(calibreBookProvider(BooksType.error).notifier).add(element);
        String exception = 'Got exception processing "${element.Title}":';
        if (e is DioException) {
          if (e.response != null) {
            if (e.response!.statusCode != null) {
              exception = '$status ${getStatusMessage(e.response!.statusCode!)}';
            } else {
              exception = '$status $e';
            }
            status.addStatus(exception);
          }
        }
      }

      state = state.copyWith(progress: index++ / total);
    }
  }

  Future<void> _updateReadStatuses() async {
    var status = ref.read(statusProvider.notifier);
    var calibre = ref.read(calibreDioProvider);
    int lastConnected = ref.read(calibreLastConnectedDateProvider.notifier).lastConnected;

    List<Book> books = await ref.read(booksRepositoryProvider.notifier).getReadingList(lastConnected);
    List<JSONBook> jsonBooks = books.map((book) => book.toJSON()).toList();

    status.addStatus('Updating Last Read statuses.');
    calibre.updateBooks(jsonBooks);
    status.addStatus('Updated Last Read statuses.');
  }
}