import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../interfaces/database_notifier.dart';
import '../models/shelf.dart';
import '../providers/calibre_ws.dart';
import '../repositories/shelf_repository.dart';
import '../utils/iterable.dart';import '../models/collection.dart';

part 'shelves_repository.g.dart';

@riverpod
class ShelvesRepository extends _$ShelvesRepository implements DatabaseNotifier {
  static const String shelvesTable = 'shelves';

  static const String shelves = '''
        create table if not exists shelves(
          name text not null,
          type int not null,
          size int not null);
          ''';

  @override
  Future<List<int>> build() async {
    ref.read(calibreWSProvider.notifier).addUpdateNotifier(this);
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

  @override
  Future<void> updateStateFromDb() async {
    List<int> current = state.value!;

    for (int shelf in current) {
      ref.read(shelfRepositoryProvider(shelf).notifier).updateShelf();
    }
  }

  Future<void> updateShelfForSeries(String seriesName) async {
    final List<int> shelfIds = state.value ?? [];
    final libraryDb = ref.read(libraryDBProvider.notifier);

    int? fullyReadShelfId;
    int? firstCandidateId;

    for (final shelfId in shelfIds) {
      final shelf = ref.read(shelfRepositoryProvider(shelfId)).value;
      if (shelf == null) continue;
      if (shelf.collection.type == CollectionType.CURRENT || shelf.collection.type == CollectionType.RANDOM) continue;

      firstCandidateId ??= shelfId;

      if (shelf.collection.type == CollectionType.SERIES) {
        final results = await libraryDb.rawQuery(
          sql: 'SELECT COUNT(*) as count FROM books WHERE series = (SELECT id FROM series WHERE series = ?) AND readStatus = 0',
          args: [shelf.name],
        );
        final unread = results.isEmpty ? 1 : (results.first['count'] as int);
        if (unread == 0) {
          fullyReadShelfId = shelfId;
          break;
        }
      }
    }

    final targetId = fullyReadShelfId ?? firstCandidateId;
    if (targetId == null) return;

    await ref.read(shelfRepositoryProvider(targetId).notifier).updateShelfToSeries(seriesName);
  }

  Future<List<int>> _getShelves() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    final List<Map<String, dynamic>> maps = await libraryDb.query(table: 'shelves', columns: ['rowid', 'name', 'type', 'size'], orderBy: 'rowid asc');

    return maps.map((shelf) => shelf['rowid'] as int).toList();
  }
}