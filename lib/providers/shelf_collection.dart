import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/collection.dart';

part 'shelf_collection.g.dart';

@Riverpod(keepAlive: true)
class ShelfCollection extends _$ShelfCollection {
  @override
  Collection? build(int shelfId) {
    return null;
  }

  void updateCollection(Collection collection) {
    state = collection;
  }
}