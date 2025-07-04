import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book.dart';
import '../models/calibre_sync_data.dart';
import '../models/json_book.dart';
import '../providers/cached_cover.dart';
import '../providers/calibre_book_provider.dart';
import '../providers/dio_provider.dart';
import '../database/library_db.dart';
import '../providers/status_provider.dart';

part 'calibre_ws.g.dart';

@Riverpod(keepAlive: true)
class CalibreWS extends _$CalibreWS {

  CalibreSyncData build() {
    return CalibreSyncData();
  }

  Future getBooks() async {
    var status = ref.read(statusProvider.notifier);
    var calibre = dioProvider();

    status.setStatus('Initialising Sync...');

    const int size = 100;
    int count = await calibre.getCount(state.syncDate);
    status.setStatus('Received $count Books in the batch.');
    
    int offset = 0;
    while (offset < count) {
      await getBooksWithOffset(offset, size, count);
      offset += size;
    }

    LibraryDB library = ref.read(libraryDBProvider.notifier);
    state = state.copyWith(syncDate: await library.setLastConnected(), status: 'Completed Synchronisation');
  }

  Future getBooksWithOffset(int offset, int size, int total) async {
    LibraryDB library = ref.read(libraryDBProvider.notifier);
    var calibre = dioProvider();
    var status = ref.read(statusProvider.notifier);

    List<JSONBook> books = await calibre.getBooks(state.syncDate, offset, size);
    String exception = "";

    int index = offset;
    for (var element in books) {
      status.setStatus('Syncing ${element.Title} ($index/$total)');

      ref.read(calibreBookProvider(BooksType.processed).notifier).add(element);
      try {
        Book book = await Book.fromJSON(element);

        // Only download the Book if something has changed since last time!
        if (book.lastModified > await library.getLastModified(book)) {
          status.setStatus('Downloading ${element.Title} ($index/$total)');
          await _downloadBook(book);
          await library.insertBook(book);
        }
      } catch (e) {
        ref.read(calibreBookProvider(BooksType.error).notifier).add(element);
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

      state = state.copyWith(progress: index++ / total);
    }
  }

  Future setSyncFromEpoch(bool? syncFrom) async {
    if (syncFrom != null) {
      state = state.copyWith(syncFromEpoch: syncFrom);
    }

    return;
  }

  Future<void> _downloadBook(Book book) async {
    final file = File(book.path);
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
    ref.read(cachedCoverProvider(book).notifier).cacheCover();
  }
}