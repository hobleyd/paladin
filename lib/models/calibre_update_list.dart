import 'package:json_annotation/json_annotation.dart';

part 'calibre_update_list.g.dart';

@JsonSerializable()
class CalibreUpdateList {
  String title;
  String author;

  @JsonKey(name: 'last_modified')
  int lastModified;

  CalibreUpdateList({
    required this.title, required this.author, required this.lastModified,
  });

  /// Connect the generated [_$CalibreUpdateListFromJson] function to the `fromJson` factory.
  factory CalibreUpdateList.fromJson(Map<String, dynamic> json) => _$CalibreUpdateListFromJson(json);

  /// Connect the generated [_$CalibreUpdateListToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$CalibreUpdateListToJson(this);
}