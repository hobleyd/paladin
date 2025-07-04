
import 'package:paladin/database/library_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book.dart';
import '../models/collection.dart';

part 'shelf_repository.g.dart';

@riverpod
class ShelfRepository extends _$ShelfRepository {
  @override
  Future<List<Book>> build(Collection collection) async {
    return _getCollection(collection);
  }

  void updateCollection(Collection coll) async {
    state = AsyncValue.data(await _getCollection(coll));
  }

  Future<List<Book>> _getCollection(Collection coll) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);

    List<Map<String, dynamic>> results = await libraryDb.rawQuery(sql: coll.query!, args: coll.queryArgs);
    return Future.wait(results.map((element) async => await Book.fromMap(libraryDb, element)).toList());
  }
}