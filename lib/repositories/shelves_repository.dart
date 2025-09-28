
import 'package:paladin/repositories/shelf_repository.dart';
import 'package:paladin/utils/iterable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../models/collection.dart';
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
  Future<List<int>> build() async {
    return await _getShelves();
  }

  Future<void> addShelf() async {
    List<int> current = List.from(state.value!);
    int newShelfId = current.max+1;
    current.add(newShelfId);

    ref.read(shelfRepositoryProvider(newShelfId).notifier).updateState(
        Shelf(
            shelfId: newShelfId,
            name: Collection.collectionType(CollectionType.RANDOM),
            collection: Collection(
              type: CollectionType.RANDOM,
              query: Shelf.shelfQuery[CollectionType.RANDOM]!,
              queryArgs: [10],
            ),
            size: 10)
    );

    state = AsyncValue.data(current);
  }

  Future<void> removeShelf() async {
    List<int> current = state.value!;

    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.rawQuery(sql: 'delete from shelves where rowid = ?', args: [current.last]);

    current.remove(current.last);
    state = AsyncValue.data(current);
  }

  Future<void> updateShelves() async {
    List<int> current = state.value!;

    for (int shelf in current) {
      ref.read(shelfRepositoryProvider(shelf).notifier).updateShelf();
    }
  }

  Future<List<int>> _getShelves() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    final List<Map<String, dynamic>> maps = await libraryDb.query(table: 'shelves', columns: ['rowid', 'name', 'type', 'size'], orderBy: 'rowid asc');

    return maps.map((shelf) => shelf['rowid'] as int).toList();
  }
}