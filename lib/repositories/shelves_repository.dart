
import 'package:paladin/models/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/library_db.dart';
import '../models/shelf.dart';

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
  Future<List<Shelf>> build() async {
    return await _getShelves();
  }

  Future<void> addShelf() async {
    await updateShelf(Shelf(name: "", collection: Collection(type: CollectionType.SERIES, count: 30), size: 30));
  }

  Future<void> removeShelf(Shelf shelf) {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    libraryDb.rawQuery(sql: 'delete from shelves where name = ?', args: [shelf.name]);
  }

  Future<void> updateShelf(Shelf shelf) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.insert(table: 'shelves', rows: shelf.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    // TODO: Could remove the DB call by altering state directly here
    state = AsyncValue.data(await _getShelves());
  }

  Future<List<Shelf>> _getShelves() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    final List<Map<String, dynamic>> maps = await libraryDb.query(table: 'shelves', columns: ['rowid', 'name', 'type', 'size'], orderBy: 'rowid asc');

    return maps.map((shelf) => Shelf.fromMap(shelf)).toList();
  }
}