import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../database/library_db.dart';
import 'collection.dart';

part 'uuid.g.dart';

@immutable
@JsonSerializable()
class Uuid extends Collection {
  static const String uuidQuery = 'select uuid from books where title like ? order by added desc;';

  final String uuid;

  const Uuid({
    required this.uuid,
    super.type = CollectionType.BOOK,
    super.query = Uuid.uuidQuery,
    super.queryArgs,
  });

  @override
  String getLabel() {
    return uuid;
  }

  factory Uuid.fromJson(Map<String, dynamic> json) => _$UuidFromJson(json);
  Map<String, dynamic> toJson() => _$UuidToJson(this);

  static Uuid fromMap(Map<String, dynamic> book) {
    return Uuid(
      uuid: book['uuid'],
      queryArgs: ['%'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
    };
  }

  @override
  String toString() {
    return uuid;
  }
}