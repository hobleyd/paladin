
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';

part 'tags_repository.g.dart';

@riverpod
class TagsRepository extends _$TagsRepository {
  static const String tagsTable = 'tags';

  static const String tags = '''
        create table if not exists $tagsTable(
          id integer primary key,
          tags text not null);
        ''';

  static const String indexTagsName = 'create index tags_name_idx on tags(tags);';

  @override
  Future<int> build() async {
    return _getTagsCount();
  }

  Future<void> updateTagsCount() async {
    state = AsyncValue.data(await _getTagsCount());
  }

  Future<int> _getTagsCount() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    return await libraryDb.getCount(tagsTable);
  }
}