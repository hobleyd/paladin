enum CollectionType { AUTHOR, BOOK, SERIES, TAG, CURRENT, RANDOM, SETTINGS, APPS }

class Collection {
  final CollectionType type;
  int count = 0;
  String? query;
  List<dynamic>? queryArgs;
  String? key;

  Collection({required this.type, this.query, this.queryArgs, this.key});

  Collection? getBookCollection() {
    return null;
  }

  String getType() {
    switch (type) {
      case CollectionType.AUTHOR:
        return key ?? 'Authors';
      case CollectionType.CURRENT:
        return 'Currently Reading';
      case CollectionType.RANDOM:
        return 'Random Shelf';
      case CollectionType.SERIES:
        return key ?? 'Series';
      case CollectionType.TAG:
        return key ?? 'Tags';
      default:
        return key ?? 'Books';
    }
  }

  @override
  String toString() {
    return 'CollectionType: $type with "$query" and args: $queryArgs';
  }
}