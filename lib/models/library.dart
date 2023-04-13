import 'package:json_annotation/json_annotation.dart';

part 'library.g.dart';

@JsonSerializable()
class Library {
  String uuid;
  String? location;
  String? calibreVersion;
  String? prefix;
  String? lastLibraryUUID;
  int? lastConnected;

  Library({
    required this.uuid,
    this.location,
    this.calibreVersion,
    this.prefix,
    this.lastLibraryUUID,
    this.lastConnected,
  });

  /// Connect the generated [_$BookFromJson] function to the `fromJson` factory.
  factory Library.fromJson(Map<String, dynamic> json) => _$LibraryFromJson(json);

  /// Connect the generated [_$BookToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$LibraryToJson(this);

  static Library fromMap(Map<String, dynamic> library) {
    return Library(
      uuid: library['uuid'],
      location: library['location'],
      calibreVersion: library['calibreVersion'],
      prefix: library['prefix'],
      lastLibraryUUID: library['lastLibraryUUID'],
      lastConnected: library['lastConnected'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'location': location,
      'calibreVersion': calibreVersion,
      'prefix': prefix,
      'lastLibraryUUID': lastLibraryUUID,
      'lastConnected': lastConnected,
    };
  }
}