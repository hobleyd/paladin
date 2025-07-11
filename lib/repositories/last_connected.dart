import 'package:paladin/database/library_db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

part 'last_connected.g.dart';

@Riverpod(keepAlive: true)
class CalibreLastConnectedDate extends _$CalibreLastConnectedDate {
  int _lastConnected = 0;
  static const String calibreTable = 'calibre_library';

  static const String calibre = '''
        create table if not exists $calibreTable (
					last_connected int);
					''';

  int get lastConnected => _lastConnected;

  @override
  Future<DateTime> build() async {
    return _getLastConnected();

  }

  Future<DateTime> _getLastConnected() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);

    final List<Map<String, dynamic>> maps = await libraryDb.query(table: 'calibre_library', limit: 1);
    _lastConnected = maps.isNotEmpty ? maps.first['last_connected'] as int : 0;
    return DateTime.fromMillisecondsSinceEpoch(_lastConnected * 1000);
  }

  Future<void> setLastConnected() async {
    DateTime now = DateTime.now();
    _lastConnected = (now.millisecondsSinceEpoch / 1000).round();
    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.insert(table: 'calibre_library', rows: { 'rowid': 0, 'last_connected': _lastConnected}, conflictAlgorithm: ConflictAlgorithm.replace);

    state = AsyncData(now);
  }
}