import 'package:json_annotation/json_annotation.dart';
import 'package:paladin/database/library_db.dart';

import 'collection.dart';

part 'author.g.dart';

@JsonSerializable()
class Author extends Collection {
  static const String authorsQuery = 'select authors.id, authors.name, count(book_authors.bookId) as count from authors left join book_authors on authors.id = book_authors.authorId where authors.name like ? group by authors.id order by authors.name';

  int? id;
  String name;

  Author({
    this.id,
    required this.name,
  }) : super(type: CollectionType.AUTHOR, count: 1, query: authorsQuery, queryArgs: [name]);

  String getAuthorNameNormalised() {
    if (name.contains(',')) {
      List<String> parts = name.split(',');
      return '${parts[1].trim()} ${parts[0].trim()}';
    }

    return name;
  }

  @override
  String getType() {
    return name;
  }

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorToJson(this);

  static Future<List<Author>> getAuthors(LibraryDB db, String uuid) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql: 'select authors.id, authors.name from book_authors, authors where book_authors.authorId = authors.id and book_authors.bookId = ?;', args: [uuid]);
    return List.generate(maps.length, (i) {
      return fromMap(maps[i]);
    });
  }

  static Author fromMap(Map<String, dynamic> author) {
    Author result =  Author(
      id: author['id'],
      name: author['name'],
    );

    if (author.containsKey('count')) {
      result.count = author['count'];
    }

    return result;
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