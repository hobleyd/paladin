import 'package:paladin/models/collection.dart';
import 'package:paladin/providers/shelf_collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/library_db.dart';
import '../models/shelf.dart';

part 'shelf_repository.g.dart';

@riverpod
class ShelfRepository extends _$ShelfRepository {
  static const String shelvesTable = 'shelves';

  static const String shelves = '''
        create table if not exists shelves(
          name text not null,
          type int not null,
          size int not null);
          ''';

  @override
  Future<Shelf> build(int shelfId) async {
    return await _getShelf(shelfId);
  }

  Future<Shelf> _getShelf(int shelfId) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    final List<Map<String, dynamic>> maps = await libraryDb.query(table: 'shelves', columns: ['rowid', 'name', 'type', 'size'], where: 'rowid = ?', whereArgs: [shelfId]);

    Shelf shelf = maps.isEmpty
        ? Shelf(
            shelfId: shelfId,
            name: Collection.collectionType(CollectionType.RANDOM),
            collection: Collection(
                type: CollectionType.RANDOM,
                query: Shelf.shelfQuery[CollectionType.RANDOM]!,
                queryArgs: [10],
                count: 10),
            size: 10)
        : maps.map((shelf) => Shelf.fromMap(shelf)).toList().first;

    ref.read(shelfCollectionProvider(shelfId).notifier).updateCollection(shelf.collection);
    return shelf;
  }

  Future<void> updateShelfCollection(CollectionType collectionType) async {
    Shelf current = state.value!;

    String name = current.name;
    if (!Shelf.shelfNeedsName(collectionType)) {
      name = "";
    }

    int size = current.size;
    if (!Shelf.shelfNeedsSize(collectionType)) {
      size = 10;
    }

    current = current.copyWith(
        shelfId: shelfId,
        name: name,
        collection: current.collection.copyWith(type: collectionType, query: Shelf.shelfQuery[collectionType]!,),
        size: size);
    updateState(current);
  }

  Future<void> updateShelfName(String name) async {
    Shelf current = state.value!;

    List<dynamic> queryArgs = [];
    if (current.collection.queryArgs != null) {
      if (current.collection.queryArgs!.length == 2) {
        queryArgs = [name, current.collection.queryArgs!.last];
      }
    }
    current = current.copyWith(name: name, collection: current.collection.copyWith(queryArgs: queryArgs));

    updateState(current);
  }

  Future<void> updateShelfSize(int size) async {
    Shelf current = state.value!;

    List<dynamic> queryArgs = [];
    if (current.collection.queryArgs != null) {
      if (current.collection.queryArgs!.isNotEmpty) {
        queryArgs = [current.collection.queryArgs!.first, size];
      }
    }

    current = current.copyWith(collection: current.collection.copyWith(count: size, queryArgs: queryArgs), size: size);
    updateState(current);
  }

  Future<void> updateState(Shelf current) async {
    ref.read(shelfCollectionProvider(current.shelfId).notifier).updateCollection(current.collection);
    state = AsyncValue.data(current);

    // TODO: Only update the DB if we have all the required fields!
    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.insert(table: 'shelves', rows: current.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}