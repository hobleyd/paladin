import 'package:flutter/material.dart';

import 'collection.dart';

class Shelf {
  int? shelfId;
  String name;
  Collection collection;
  int size;

  static const shelfQuery = {
    CollectionType.AUTHOR : 'select *, count(*) as count from books where uuid in (select bookId from book_authors, authors where authors.id = book_authors.authorId and authors.name = ?)',
    CollectionType.SERIES : 'select *, count(*) as count from books where series = (select id from series where series = ?);',
    CollectionType.TAG    : 'select *, count(*) as count from books where uuid in (select bookId from book_tags, tags where tags.id = book_tags.tagId and tags.tag = ?)',
    CollectionType.RANDOM : 'select *, count(*) as count from books order by random limit ?'
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

  Shelf({this.shelfId, required this.name, required this.collection, required this.size});

  static Shelf fromMap(Map<String, dynamic> shelf) {
    return Shelf(
      shelfId: shelf['rowid'],
      name: shelf['name'],
      collection: Collection(
          type: CollectionType.values[shelf['type']],
          count: shelf['count'],
          query: shelfQuery[shelf['type']],
          queryArgs: shelf['type'] == CollectionType.RANDOM.index ? shelf['size'] : shelf['name'],
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