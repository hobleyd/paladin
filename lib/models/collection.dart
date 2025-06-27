import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'book.dart';

enum CollectionType { AUTHOR, BOOK, SERIES, TAG, CURRENT, RANDOM, SETTINGS, APPS }

class Collection {
  final CollectionType type;
  int count = 0;
  String? query;
  List<dynamic>? queryArgs;
  String? key;

  static Map<CollectionType, String> collectionTypes = {
    CollectionType.CURRENT : 'Currently Reading',
    CollectionType.RANDOM  : 'Random Shelf',
    CollectionType.AUTHOR  : 'Authors',
    CollectionType.SERIES  : 'Series',
    CollectionType.BOOK    : 'Books',
    CollectionType.TAG     : 'Tags'
  };

  Collection({required this.type, this.query, this.queryArgs, this.key});

  Future<List<Book>> getBookCollection(Database? db) async {
    return [];
  }

  String getType() {
    return key ?? collectionTypes[type]!;
  }

  @override
  String toString() {
    return 'CollectionType: $type with "$query" and args: $queryArgs';
  }
}