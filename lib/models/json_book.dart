import 'package:json_annotation/json_annotation.dart';
import 'package:paladin/models/tag.dart';

part 'json_book.g.dart';

@JsonSerializable()
class JSONBook {
  String UUID;
  String Author;
  String Blurb;
  String? mimeType;
  int? Last_modified;
  int? Last_read;
  int? Rating;
  bool Is_read;
  String Series;
  double Series_index;
  List<Tag>? Tags;
  String Title;

  JSONBook({
    required this.UUID,
    required this.Author,
    required this.Blurb,
    this.Rating,
    this.Last_modified,
    this.Last_read,
    this.mimeType,
    required this.Is_read,
    required this.Series,
    required this.Series_index,
    this.Tags,
    required this.Title});

  /// Connect the generated [_$BookFromJson] function to the `fromJson` factory.
  factory JSONBook.fromJson(Map<String, dynamic> json) => _$JSONBookFromJson(json);

  /// Connect the generated [_$BookToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$JSONBookToJson(this);
}