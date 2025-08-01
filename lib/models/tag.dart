import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:paladin/database/library_db.dart';

import 'collection.dart';

part 'tag.g.dart';

@immutable
@JsonSerializable()
class Tag extends Collection {
  static const String tagsQuery = 'select tags.id, tags.tag, count(book_tags.tagId) as count from tags left join book_tags on tags.id = book_tags.tagId where tags.tag like ? group by tags.id order by tags.tag';

  int? id;
  String tag;

  Tag({
    this.id,
    required this.tag,
    super.type = CollectionType.TAG,
    super.query = tagsQuery,
    required super.queryArgs,
    super.count = 1,
  });

  @override
  String getLabel() {
    return tag;
  }

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);

  static Future<List<Tag>> getTags(LibraryDB db, String uuid) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql: 'select tags.id, tags.tag from book_tags, tags where book_tags.bookId = ? and book_tags.tagId = tags.id;', args: [uuid]);
    return List.generate(maps.length, (i) {
      return fromMap(maps[i]);
    });
  }

  static Tag fromMap(Map<String, dynamic> tag) {
    return Tag(
      id: tag['id'],
      tag: tag['tag'],
      queryArgs: [tag['tag']],
      count: tag['count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tag': tag,
    };
  }

  @override
  String toString() {
    return '$tag [$count]';
  }
}