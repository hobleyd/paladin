import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/json_book.dart';

part 'calibre_book_provider.g.dart';

enum BooksType { processed, error }

@Riverpod(keepAlive: true)
class CalibreBook extends _$CalibreBook {
  @override
  List<JSONBook> build(BooksType type) {
    return [];
  }

  void add(JSONBook book) {
    List<JSONBook> entities = [book, ...state];

    state = entities;
  }

  void clear() {
    state = [];
  }
}