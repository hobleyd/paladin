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
  int last_modified = 1672577852;
  List<JSONBook> returnedBooks = [];
  double progress = 0.0;
  String httpStatus = "";

  CalibreWS() {
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: "https://calibrews.sharpblue.com.au/",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 900),
      contentType: 'application/json',);
    _calibre = Calibre(dio);
  }

  Future getBooks(BuildContext context) async {
    final LibraryDB library = Provider.of<LibraryDB>(context, listen: false);

    try {
      returnedBooks = await _calibre.getBooks(last_modified);
      httpStatus = "";

      int index = 1;
      int total = returnedBooks.length;
      for (var element in returnedBooks) {
        Book book = await Book.fromJSON(element);
        await _downloadBook(book);
        await library.insertBook(book);
        progress = index++ / total;
      }
    } catch (e) {
      if (e is DioError) {
        httpStatus = getStatusMessage(e.response!.statusCode!);
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> _downloadBook(Book book) async {
    final file = File(book.path!);
    if (!file.existsSync()) {
      file.createSync(recursive: true);

      final response = _calibre.getBook(book.uuid, 4096);
      final sink = file.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
      }
      await sink.flush();
      await sink.close();
    }

    await book.getCover();
  }
}