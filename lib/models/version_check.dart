import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:version/version.dart';

part 'version_check.freezed.dart';

@immutable
@freezed
class VersionCheck with _$VersionCheck {
  @override
  final Version currentVersion;

  @override
  final Version newVersion;

  @override
  final String downloadUrl;

  @override
  final String downloadPackage;

  bool get hasUpdate => newVersion > currentVersion;

  const VersionCheck({required this.currentVersion, required this.newVersion, required this.downloadUrl, required this.downloadPackage});
}