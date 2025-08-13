import 'package:json_annotation/json_annotation.dart';

part 'book_count.g.dart';

@JsonSerializable()
class BookCount {
  int count;

  BookCount({required this.count});

  /// Connect the generated [_$BookFromJson] function to the `fromJson` factory.
  factory BookCount.fromJson(Map<String, dynamic> json) => _$BookCountFromJson(json);

  /// Connect the generated [_$BookToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$BookCountToJson(this);
}