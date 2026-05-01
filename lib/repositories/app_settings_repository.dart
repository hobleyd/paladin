import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/library_db.dart';

part 'app_settings_repository.g.dart';

@Riverpod(keepAlive: true)
class AppSettingsRepository extends _$AppSettingsRepository {
  static const String settingsTable = 'app_settings';

  static const String appSettings = '''
        create table if not exists $settingsTable(
          auto_update_shelf int not null);
          ''';

  @override
  Future<({bool autoUpdateShelf})> build() async {
    return _getSettings();
  }

  Future<({bool autoUpdateShelf})> _getSettings() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    final List<Map<String, dynamic>> maps = await libraryDb.query(table: settingsTable, limit: 1);

    if (maps.isEmpty) {
      await _insertDefaults(libraryDb);
      return (autoUpdateShelf: true);
    }

    return (autoUpdateShelf: (maps.first['auto_update_shelf'] as int) != 0);
  }

  Future<void> _insertDefaults(LibraryDB libraryDb) async {
    await libraryDb.insert(
      table: settingsTable,
      rows: {'rowid': 1, 'auto_update_shelf': 1},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> updateAutoUpdateShelf(bool enabled) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.insert(
      table: settingsTable,
      rows: {'rowid': 1, 'auto_update_shelf': enabled ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    state = AsyncData((autoUpdateShelf: enabled));
  }
}
