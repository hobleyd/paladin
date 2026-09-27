import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Redirects path_provider's platform channel lookups to a directory the
/// test controls, so [getApplicationDocumentsDirectory] and friends work
/// under `flutter test` without a real platform channel.
class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform(this._path);

  final String _path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;

  @override
  Future<String?> getLibraryPath() async => _path;

  @override
  Future<String?> getTemporaryPath() async => _path;

  @override
  Future<String?> getApplicationCachePath() async => _path;
}
