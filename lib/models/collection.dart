
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

  String getType() {
    return collectionTypes[type]!;
  }

  @override
  String toString() {
    return 'CollectionType: $type with "$query" and args: $queryArgs';
  }
}