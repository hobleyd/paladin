import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/json_book.dart';

part 'books_provider.g.dart';

enum BooksType { processed, error }

@Riverpod(keepAlive: true)
class Books extends _$Books {
  @override
  List<JSONBook> build(BooksType type) {
    return [];
  }

  void add(JSONBook book) {
    List<JSONBook> entities = [...state, book];
    entities.sort((a, b) => a.Title.compareTo(b.Title));

    state = entities;
  }

  void clear() {
    state = [];
  }
}