import 'package:flutter/foundation.dart';
import 'package:paladin/database/library_db.dart';
import 'package:paladin/models/calibre_server.dart';
import 'package:paladin/providers/calibre_network_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

part 'calibre_server_repository.g.dart';

@Riverpod(keepAlive: true)
class CalibreServerRepository extends _$CalibreServerRepository {
  static const String calibreTable = 'calibre_library';

  static const String calibre = '''
        create table if not exists $calibreTable (
          calibre_server text,
					last_connected int);
					''';

  @override
  Future<CalibreServer> build() async {
    return _getServerDetails();
  }

  Future<CalibreServer> _getServerDetails() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);

    final List<Map<String, dynamic>> maps = await libraryDb.query(table: 'calibre_library', limit: 1);
    return maps.isEmpty
      ? CalibreServer(calibreServer: "", lastConnected: 0)
        : CalibreServer(
        calibreServer: maps.first['calibre_server'] ?? "",
        lastConnected: maps.first['last_connected'] as int ?? 0);
  }

  Future<void> updateServerDetails({String? calibre_server, int? lastConnected}) async {
    CalibreServer server = state.value!;
    CalibreServer updatedServer = server.copyWith(calibreServer: calibre_server, lastConnected: lastConnected);

    var libraryDb = ref.read(libraryDBProvider.notifier);
    await libraryDb.insert(
        table: 'calibre_library',
        rows: { 'rowid': 0, 'calibre_server': updatedServer.calibreServer, 'last_connected': updatedServer.lastConnected},
        conflictAlgorithm: ConflictAlgorithm.replace);

    state = AsyncData(updatedServer);
  }
}