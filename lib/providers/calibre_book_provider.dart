import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book.dart';

part 'calibre_book_provider.g.dart';

enum BooksType { processed, error }

@Riverpod(keepAlive: true)
class CalibreBook extends _$CalibreBook {
  @override
  List<Book> build(BooksType type) {
    return [];
  }

  void add(Book book) {
    List<Book> entities = [book, ...state];

    state = entities;
  }

  void clear() {
    state = [];
  }
}