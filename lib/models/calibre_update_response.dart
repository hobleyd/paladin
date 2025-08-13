import 'package:json_annotation/json_annotation.dart';

part 'calibre_update_response.g.dart';

@JsonSerializable()
class CalibreUpdateResponse {
  String status;
  String message;

  CalibreUpdateResponse({required this.status, required this.message});

  factory CalibreUpdateResponse.fromJson(Map<String, dynamic> json) => _$CalibreUpdateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CalibreUpdateResponseToJson(this);
}