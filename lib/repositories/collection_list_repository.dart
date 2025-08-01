import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../models/collection.dart';
import '../models/series.dart';
import '../models/tag.dart';

part 'collection_list_repository.g.dart';

@riverpod
class CollectionListRepository extends _$CollectionListRepository {
  @override
  Future<List<Collection>> build(Collection collection) async {
    return _getCollection(collection);
  }

  Future<List<Collection>> _getCollection(Collection collection) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);

    List<Map<String, dynamic>> results = await libraryDb.rawQuery(sql: collection.query, args: collection.queryArgs);
    if (results.isEmpty || results[0]['count'] == 0) {
      return [];
    }

    return await Future.wait(results.map((element) async => switch (collection.type) {
      CollectionType.AUTHOR => Author.fromMap(element),
      CollectionType.BOOK   => Book.fromMap(libraryDb, element),
      CollectionType.SERIES => Series.fromMap(element),
      CollectionType.TAG    => Tag.fromMap(element),
      _ => throw UnimplementedError(),
    }));
  }

  void updateCollection(Collection collection) async {
    state = await AsyncValue.guard(() => _getCollection(collection));
  }
}