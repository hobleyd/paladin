import 'package:json_annotation/json_annotation.dart';

part 'calibre_health.g.dart';

@JsonSerializable()
class CalibreHealth {
  String status;
  String message;
  DateTime timestamp;
  Map<String, String> endpoints;

  CalibreHealth({
      required this.status,
      required this.message,
      required this.timestamp,
      required this.endpoints,
  });

  /// Connect the generated [_$CalibreHealthFromJson] function to the `fromJson` factory.
  factory CalibreHealth.fromJson(Map<String, dynamic> json) => _$CalibreHealthFromJson(json);

  /// Connect the generated [_$CalibreHealthToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$CalibreHealthToJson(this);
}