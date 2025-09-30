
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../interfaces/database_notifier.dart';
import '../providers/calibre_ws.dart';

part 'authors_repository.g.dart';

@riverpod
class AuthorsRepository extends _$AuthorsRepository implements DatabaseNotifier{
  static const String authorsTable = 'authors';

  static const String authors = '''
        create table if not exists authors(
          id integer primary key,
          name text not null,
          unique (name) on conflict ignore);
          ''';

  static const String indexAuthors = 'create index authors_idx on authors(name);';

  @override
  Future<int> build() async {
    ref.read(calibreWSProvider.notifier).addUpdateNotifier(this);
    return _getAuthorsCount();
  }

  @override
  Future<void> updateStateFromDb() async {
    state = AsyncValue.data(await _getAuthorsCount());
  }

  Future<int> _getAuthorsCount() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    return await libraryDb.getCount(authorsTable);
  }
}