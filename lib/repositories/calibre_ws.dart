import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book.dart';
import '../models/json_book.dart';
import '../providers/books_provider.dart';
import '../providers/dio_provider.dart';
import '../providers/library_db.dart';
import '../providers/status_provider.dart';


@Riverpod(keepAlive: true)
CalibreWS calibreProvider() {
  return CalibreWS();
}

class CalibreWS {
  bool syncFromEpoch = false;
  int syncDate = 0;
  double progress = 0.0;
  String status = "";

  CalibreWS(WidgetRef ref) {
    _getLastSyncDate();
  }

  Future getBooks() async {
    var status = ref.read(statusProvider.notifier);
    var library = paladinDatabase();
    var calibre = dioProvider();

    status.setStatus('Initialising Sync...');

    const int size = 100;
    int count = await calibre.getCount(syncDate);
    status.setStatus('Received $count Books in the batch.');
    
    int offset = 0;
    while (offset < count) {
      await getBooksWithOffset(ref, library, offset, size, count);
      offset += size;
    }

    syncDate = await library.setLastConnected();
    status.setStatus('Completed Synchronisation');
  }

  Future getBooksWithOffset(WidgetRef ref, LibraryDB library, int offset, int size, int total) async {
    var calibre = dioProvider();
    var status = ref.read(statusProvider.notifier);
    var library = paladinDatabase();

    List<JSONBook> books = await calibre.getBooks(syncDate, offset, size);
    String exception = "";

    int index = offset;
    for (var element in books) {
      status.setStatus('Syncing ${element.Title} ($index/$total)');

      ref.read(booksProvider(BooksType.processed).notifier).add(element);
      try {
        Book book = await Book.fromJSON(element);

        // Only download the Book if something has changed since last time!
        if (book.lastModified == null || book.lastModified! > await library.getLastModified(book)) {
          status.setStatus('Downloading ${element.Title} ($index/$total)');
          await _downloadBook(book);
          await library.insertBook(book);
        }
      } catch (e) {
        ref.read(booksProvider(BooksType.error).notifier).add(element);
        exception = 'Got exception processing "${element.Title}":';
        if (e is DioException) {
          if (e.response != null) {
            if (e.response!.statusCode != null) {
              exception = '$status ${getStatusMessage(e.response!.statusCode!)}';
            } else {
              exception = '$status $e';
            }
            status.setStatus(exception);
          }
        }
      }

      progress = index++ / total;
    }
  }

  Future setSyncFromEpoch(bool? syncFrom) async {
    if (syncFrom != null) {
      syncFromEpoch = syncFrom;
      _getLastSyncDate();
    }

    return;
  }

  Future<void> _downloadBook(Book book) async {
    final file = File(book.path!);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    final response = dioProvider().getBook(book.uuid, 4096);
    final sink = file.openWrite();
    await for (final chunk in response) {
      sink.add(chunk);
    }
    await sink.flush();
    await sink.close();
    await book.cacheCover();
  }

  Future<void> _getLastSyncDate() async {
    syncDate = syncFromEpoch ? 0 : await paladinDatabase().getLastConnected();

    notifyListeners();
  }
}