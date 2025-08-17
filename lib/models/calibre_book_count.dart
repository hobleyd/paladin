import 'package:json_annotation/json_annotation.dart';

part 'calibre_book_count.g.dart';

@JsonSerializable()
class CalibreBookCount {
  int count;

  CalibreBookCount({
    required this.count,
  });

  /// Connect the generated [_$CalibreHealthFromJson] function to the `fromJson` factory.
  factory CalibreBookCount.fromJson(Map<String, dynamic> json) => _$CalibreBookCountFromJson(json);

  /// Connect the generated [_$CalibreHealthToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$CalibreBookCountToJson(this);
}