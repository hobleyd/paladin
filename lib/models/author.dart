import 'package:flutter/foundation.dart';
import 'package:paladin/database/library_db.dart';
import 'package:paladin/utils/normalised.dart';

import 'collection.dart';

@immutable
class Author extends Collection {
  static const String authorsQuery = 'select authors.id, authors.name, count(book_authors.bookId) as count from authors left join book_authors on authors.id = book_authors.authorId where authors.name like ? group by authors.id order by authors.name';

  final int? id;
  final String name;
  final int? count;

  const Author({
    this.id,
    required this.name,
    this.count,
    super.type = CollectionType.AUTHOR,
    super.query = authorsQuery,
    required super.queryArgs,
  });

  Author copyAuthorWith({int? id, String? name}) {
    return Author(
      id: id ?? this.id,
      name: name ?? this.name,
      queryArgs: queryArgs ?? [name],
    );
  }

  @override
  String getNameNormalised() {
    return name.contains(',') ? getNormalisedString(name) : name;
  }

  @override
  String getLabel() {
    return name;
  }

  static Future<List<Author>> getAuthors(LibraryDB db, String uuid) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql: 'select authors.id, authors.name from book_authors, authors where book_authors.authorId = authors.id and book_authors.bookId = ?;', args: [uuid]);
    return List.generate(maps.length, (i) {
      return fromMap(maps[i]);
    });
  }

  static Author fromMap(Map<String, dynamic> author) {
    return Author(
      id: author['id'],
      name: author['name'],
      queryArgs: [author['name']],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return '$name [$count]';
  }
}