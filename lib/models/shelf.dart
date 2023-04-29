import 'package:flutter/material.dart';

import 'collection.dart';

class Shelf {
  int? shelfId;
  String name;
  CollectionType type;
  int size;

  static const shelfQuery = {
    CollectionType.AUTHOR : 'select * from books where uuid in (select bookId from book_authors, authors where authors.id = book_authors.authorId and authors.name = ?)',
    CollectionType.SERIES : 'select * from books where series = (select id from series where series = ?);',
    CollectionType.TAG    : 'select * from books where uuid in (select bookId from book_tags, tags where tags.id = book_tags.tagId and tags.tag = ?)'
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

  Shelf({this.shelfId, required this.name, required this.type, required this.size});

  static Shelf fromMap(Map<String, dynamic> shelf) {
    return Shelf(
      shelfId: shelf['rowid'],
      name: shelf['name'],
      type: CollectionType.values[shelf['type']],
      size: shelf['size']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rowid': shelfId,
      'name' : name,
      'type' : type.index,
      'size' : size
    };
  }

  @override
  String toString() {
    return '$shelfId, $name, $type, $size';
  }
}