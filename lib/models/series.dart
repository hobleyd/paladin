import 'package:flutter/foundation.dart';
import 'package:paladin/database/library_db.dart';
import 'package:paladin/utils/normalised.dart';

import 'collection.dart';

@immutable
class Series extends Collection {
  static const String seriesQuery = 'select series.id, series.series, count(books.uuid) as count from series left join books on books.series = series.id where series.series like ? group by series.id order by series.series;';

  final int? id;
  final String series;
  final int? count;

  const Series({
    this.id,
    required this.series,
    this.count,
    super.type = CollectionType.SERIES,
    super.query = seriesQuery,
    required super.queryArgs,
  });

  Series copySeriesWith({int? id, }) {
    return Series(
      id:        id ?? this.id,
      query:     query,
      queryArgs: queryArgs,
      series:    series,
      type:      type,
    );
  }

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
    return Series(
      id: series['id'],
      series: series['series'],
      queryArgs: [series['series']],
      count: series['count'] ?? series.length,
    );
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