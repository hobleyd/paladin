import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_status_code/http_status_code.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/json_book.dart';
import '../services/calibre.dart';
import 'library_db.dart';

class CalibreWS extends ChangeNotifier {
  late Calibre _calibre;
  late LibraryDB _library;
  bool syncFromEpoch = false;
  int syncDate = 0;
  List<JSONBook> processedBooks = [];
  List<JSONBook> errors = [];
  bool processing = false;
  double progress = 0.0;
  String httpStatus = "";

  CalibreWS(BuildContext context) {
    _library = Provider.of<LibraryDB>(context, listen: false);
    _getLastSyncDate();

    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: "https://calibrews.sharpblue.com.au/",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 900),
      contentType: 'application/json',);
    _calibre = Calibre(dio);
  }

  Future getBooks(BuildContext context) async {
    processing = true;
    const int size = 100;
    int count = await _calibre.getCount(syncDate);

    int offset = 0;
    while (offset < count) {
      await getBooksWithOffset(_library, offset, size, count);
      offset += size;
    }

    debugPrint('${errors.length} errors: $errors');
    _library.setLastConnected();
    processing = false;
  }

  Future getBooksWithOffset(LibraryDB library, int offset, int size, int total) async {
    List<JSONBook> books = await _calibre.getBooks(syncDate, offset, size);
    httpStatus = "";

    int index = offset;
    for (var element in books) {
      processedBooks.insert(0, element);
      try {
        Book book = await Book.fromJSON(element);

        // Only download the Book if something has changed since last time!
        if (book.lastModified == null || book.lastModified! > await library.getLastModified(book)) {
          await _downloadBook(book);
          await library.insertBook(book);
        }
      } catch (e) {
        errors.add(element);
        debugPrint('Got exception processing "${element.Title}": $e');
        if (e is DioError) {
          if (e.response != null) {
            if (e.response!.statusCode != null) {
              httpStatus = getStatusMessage(e.response!.statusCode!);
            } else {
              httpStatus = '$e';
            }
          }
        }
      }

      progress = index++ / total;
      notifyListeners();
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

    final response = _calibre.getBook(book.uuid, 4096);
    final sink = file.openWrite();
    await for (final chunk in response) {
      sink.add(chunk);
    }
    await sink.flush();
    await sink.close();
    await book.cacheCover();
  }

  Future<void> _getLastSyncDate() async {
    syncDate = syncFromEpoch ? 0 : await _library.getLastConnected();

    notifyListeners();
  }
}