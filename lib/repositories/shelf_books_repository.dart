import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../models/book.dart';
import '../models/collection.dart';

part 'shelf_books_repository.g.dart';

@riverpod
class ShelfBooksRepository extends _$ShelfBooksRepository {
  @override
  Future<List<String>> build(Collection collection) async {
    return _getCollection(collection);
  }

  void updateCollection(Collection coll) async {
    state = AsyncValue.data(await _getCollection(coll));
  }

  Future<List<String>> _getCollection(Collection coll) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);

    List<Map<String, dynamic>> results = await libraryDb.rawQuery(sql: coll.query, args: coll.queryArgs);
    if (results.isEmpty || results[0]['count'] == 0) {
      return [];
    }

    List<Book> books = await Future.wait(results.map((element) async => await Book.fromMap(libraryDb, element)).toList());
    return books.map((book) => book.uuid).toList();
  }
}