import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../models/author.dart';
import '../models/collection.dart';
import '../models/series.dart';
import '../models/tag.dart';

part 'collection_repository.g.dart';

@riverpod
class CollectionRepository extends _$CollectionRepository {
  @override
  Future<List<Collection>> build(Collection collection) async {
    return _getCollection(collection);
  }

  Future<List<Collection>> _getCollection(Collection coll) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);

    List<Map<String, dynamic>> results = await libraryDb.rawQuery(sql: coll.query, args: coll.queryArgs);
    if (results.isEmpty || results[0]['count'] == 0) {
      return [];
    }

    List<Collection> details = results.map((element) => switch (coll.type) {
      CollectionType.AUTHOR => Author.fromMap(element),
      CollectionType.SERIES => Series.fromMap(element),
      CollectionType.TAG => Tag.fromMap(element),
      _ => throw UnimplementedError(),
    }).toList();

    return details as List<Collection>;
  }
}