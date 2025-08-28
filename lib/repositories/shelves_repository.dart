
import 'package:paladin/repositories/shelf_repository.dart';
import 'package:paladin/utils/iterable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';

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
    current.add(current.max+1);

    // We don't update the DB here as the Shelf will need to be populated with valid content, first.
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

    current.map((shelf) => ref.read(shelfRepositoryProvider(shelf).notifier).updateShelf());
  }

  Future<List<int>> _getShelves() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    final List<Map<String, dynamic>> maps = await libraryDb.query(table: 'shelves', columns: ['rowid', 'name', 'type', 'size'], orderBy: 'rowid asc');

    return maps.map((shelf) => shelf['rowid'] as int).toList();
  }
}