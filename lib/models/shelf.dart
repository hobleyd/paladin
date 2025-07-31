import 'package:flutter/foundation.dart';

import 'collection.dart';

@immutable
class Shelf {
  int shelfId;
  String name;
  Collection collection;
  int size;

  static const shelfQuery = {
    CollectionType.AUTHOR  : 'select * from books where uuid in (select bookId from book_authors, authors where authors.id = book_authors.authorId and authors.name = ?)',
    CollectionType.SERIES  : 'select * from books where series = (select id from series where series = ?);',
    CollectionType.TAG     : 'select * from books where uuid in (select bookId from book_tags, tags where tags.id = book_tags.tagId and tags.tag = ?) order by random() limit ?',
    CollectionType.RANDOM  : 'select * from books order by random() limit ?',
    CollectionType.CURRENT : 'select * from books where lastRead > 0 order by lastRead DESC limit ?'
  };

  static const shelfTable = {
    CollectionType.AUTHOR : 'authors',
    CollectionType.SERIES : 'series',
    CollectionType.TAG    : 'tags',
  };

  static const shelfTableColumn = {
    CollectionType.AUTHOR : 'name',
    CollectionType.SERIES : 'series',
    CollectionType.TAG    : 'tag',
  };

  CollectionType get type => collection.type;
  bool get needsName => shelfNeedsName(type);
  bool get needsSize => shelfNeedsSize(type);

  Shelf({required this.shelfId, required this.name, required this.collection, required this.size});

  static bool shelfNeedsName(CollectionType type) => [CollectionType.BOOK, CollectionType.TAG, CollectionType.AUTHOR, CollectionType.SERIES].contains(type);
  static bool shelfNeedsSize(CollectionType type) => [CollectionType.TAG, CollectionType.CURRENT, CollectionType.RANDOM].contains(type);

  Shelf copyWith({int? shelfId, String? name, Collection? collection, int? size}) {
    return Shelf(
      shelfId: shelfId ?? this.shelfId,
      name: name ?? this.name,
      collection: collection ?? this.collection,
      size: size ?? this.size,
    );
  }

  static Shelf fromMap(Map<String, dynamic> shelf) {
    CollectionType type = CollectionType.values[shelf['type']];
    return Shelf(
      shelfId: shelf['rowid'],
      name: shelf['name'],
      collection: Collection(
          type: type,
          count: shelf.length,
          query: shelfQuery[CollectionType.values[shelf['type']]]!,
          queryArgs: [
              if (shelfNeedsName(type)) ...[shelf['name']],
              if (shelfNeedsSize(type)) ...[shelf['size']],
        ],
      ),
      size: shelf['size']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rowid': shelfId,
      'name' : name,
      'type' : collection.type.index,
      'size' : size
    };
  }

  @override
  String toString() {
    return '$shelfId, $name, $collection, $size';
  }
}