
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../interfaces/database_notifier.dart';
import '../providers/calibre_ws.dart';

part 'tags_repository.g.dart';

@riverpod
class TagsRepository extends _$TagsRepository implements DatabaseNotifier {
  static const String tagsTable = 'tags';

  static const String tags = '''
        create table if not exists $tagsTable(
          id integer primary key,
          tags text not null);
        ''';

  static const String indexTagsName = 'create index tags_name_idx on tags(tags);';

  @override
  Future<int> build() async {
    ref.read(calibreWSProvider.notifier).addUpdateNotifier(this);
    return _getTagsCount();
  }

  @override
  Future<void> updateStateFromDb() async {
    state = AsyncValue.data(await _getTagsCount());
  }

  Future<int> _getTagsCount() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    return await libraryDb.getCount(tagsTable);
  }
}