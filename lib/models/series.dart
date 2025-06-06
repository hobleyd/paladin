import 'package:sqflite_common/sqlite_api.dart';

import 'collection.dart';

class Series extends Collection {
  static const String seriesQuery = 'select series.id, series.series, count(books.uuid) as count from series left join books on books.series = series.id where series.series like ? group by series.id order by series.series;';

  int? id;
  String series;

  Series({
    this.id,
    required this.series,
  }) : super(type: CollectionType.SERIES);

  String getSeriesNameNormalised() {
    if (series.contains(',')) {
      List<String> parts = series.split(',');
      return '${parts[1].trim()} ${parts[0].trim()}';
    }

    return series;
  }

  @override
  String getType() {
    return queryArgs?[0] ?? series;
  }

  static Future<Series> getSeries(Database db, int seriesId) async {
    final List<Map<String, dynamic>> maps = await db.query('series', where: 'id = ?', whereArgs: [seriesId]);
    return fromMap(maps[0]);
  }

  @override
  Collection? getBookCollection() {
    return Collection(type: CollectionType.BOOK, query: 'select * from books where series = ?', queryArgs: [id!], key: series);
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
    return '$series with id $id';
  }
}