
import 'package:paladin/models/shelf.dart';
import 'package:paladin/utils/normalised.dart';

enum CollectionType { AUTHOR, BOOK, SERIES, TAG, CURRENT, RANDOM, SETTINGS, APPS }

class Collection {
  CollectionType type;
  int count = 0;
  String query;
  List<dynamic>? queryArgs;

  static Map<CollectionType, String> collectionTypes = {
    CollectionType.CURRENT : 'Currently Reading',
    CollectionType.RANDOM  : 'Random Shelf',
    CollectionType.AUTHOR  : 'Authors',
    CollectionType.SERIES  : 'Series',
    CollectionType.BOOK    : 'Books',
    CollectionType.TAG     : 'Tags'
  };

  Collection({ required this.type, required this.query, this.queryArgs, required this.count });

  String getLabel() {
    return switch (type) {
      CollectionType.CURRENT => collectionTypes[type]!,
      CollectionType.RANDOM => collectionTypes[type]!,
      _ => Shelf.shelfNeedsName(type) ? queryArgs?.first.contains(',') ? getNormalisedString(queryArgs?.first!) : queryArgs?.first : queryArgs?.first,
    };
  }

  String getNameNormalised() {
    return getLabel();
  }

  @override
  String toString() {
    return 'CollectionType: $type with "$query" and args: $queryArgs';
  }
}