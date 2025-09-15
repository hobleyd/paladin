import 'package:json_annotation/json_annotation.dart';

part 'calibre_update_list.g.dart';

@JsonSerializable()
class CalibreUpdateList {
  String title;
  String author;
  int last_modified;

  CalibreUpdateList({
    required this.title, required this.author, required this.last_modified,
  });

  /// Connect the generated [_$CalibreHealthFromJson] function to the `fromJson` factory.
  factory CalibreUpdateList.fromJson(Map<String, dynamic> json) => _$CalibreUpdateListFromJson(json);

  /// Connect the generated [_$CalibreHealthToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$CalibreUpdateListToJson(this);
}