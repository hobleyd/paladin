import 'package:paladin/database/library_db.dart';
import 'package:paladin/utils/normalised.dart';

import 'collection.dart';

class Series extends Collection {
  static const String seriesQuery = 'select series.id, series.series, count(books.uuid) as count from series left join books on books.series = series.id where series.series like ? group by series.id order by series.series;';

  int? id;
  String series;

  Series({
    this.id,
    required this.series,
  }) : super(type: CollectionType.SERIES, count: 1, query: seriesQuery, queryArgs: [series]);

  @override
  String getNameNormalised() {
    return series.contains(',') ? getNormalisedString(series) : series;
  }

  @override
  String getLabel() {
    return queryArgs?[0] ?? series;
  }

  static Future<Series> getSeries(LibraryDB db, int seriesId) async {
    final List<Map<String, dynamic>> maps = await db.query(table: 'series', where: 'id = ?', whereArgs: [seriesId]);
    return fromMap(maps[0]);
  }

  static Series fromMap(Map<String, dynamic> series) {
    Series result = Series(
      id: series['id'],
      series: series['series'],
    );

    if (series.containsKey('count')) {
      result.count = series['count'];
    }

    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'series': series,
    };
  }

  @override
  String toString() {
    return '$series [$count]';
  }
}