
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/library_db.dart';
import '../interfaces/database_notifier.dart';
import '../providers/calibre_ws.dart';

part 'series_repository.g.dart';

@riverpod
class SeriesRepository extends _$SeriesRepository implements DatabaseNotifier {
  static const String seriesTable = 'series';

  static const String series = '''
        create table if not exists $seriesTable(
          id integer primary key,
          series text not null);
        ''';

  static const String indexSeriesName = 'create index series_name_idx on series(series);';

  @override
  Future<int> build() async {
    ref.read(calibreWSProvider.notifier).addUpdateNotifier(this);
    return _getSeriesCount();
  }

  @override
  Future<void> updateStateFromDb() async {
    state = AsyncValue.data(await _getSeriesCount());
  }

  Future<int> _getSeriesCount() async {
    var libraryDb = ref.read(libraryDBProvider.notifier);
    return await libraryDb.getCount(seriesTable);
  }
}