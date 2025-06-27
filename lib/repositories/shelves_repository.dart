
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../models/book.dart';
import '../models/collection.dart';

part 'shelves_repository.g.dart';

@riverpod
class ShelvesRepository extends _$ShelvesRepository {
  static const String shelvesTable = 'shelves';

  static const String shelves = '''
        create table if not exists shelves(
          name text not null,
          type int not null,
          size int not null);
          ''';

  @override
  Future<List<Book>> build(Collection collection) async {
    return _getCollection(collection);
  }

  Future<List<Book>> _getCollection(Collection collection) async {
    var libraryDb = ref.read(libraryDBProvider);
    return await collection.getBookCollection(libraryDb.value);
  }
}