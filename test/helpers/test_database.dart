import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:paladin/database/library_db.dart';
import 'package:riverpod/misc.dart' show Override;

import 'fake_path_provider.dart';

/// A [ProviderContainer] backed by a real, freshly-created sqlite database
/// in a temp directory (via a faked path_provider platform), for tests that
/// exercise repositories/providers against real SQL rather than mocks.
///
/// Only use from a plain `test()`, not from `testWidgets()`: the underlying
/// `databaseFactoryFfi` dispatches every query to a background isolate,
/// which needs the real event loop to respond — see
/// `test/helpers/pump_until.dart` for the `testWidgets` equivalent.
class TestDatabase {
  TestDatabase._(this.container, this._tempDir);

  final ProviderContainer container;
  final Directory _tempDir;

  static Future<TestDatabase> open({List<Override> overrides = const []}) async {
    final tempDir = Directory.systemTemp.createTempSync('paladin_db_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);

    final container = ProviderContainer(overrides: overrides);
    await container.read(libraryDBProvider.future);

    return TestDatabase._(container, tempDir);
  }

  LibraryDB get db => container.read(libraryDBProvider.notifier);

  void dispose() {
    container.dispose();
    _tempDir.deleteSync(recursive: true);
  }
}
