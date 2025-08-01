
import 'package:flutter/foundation.dart';
import 'package:paladin/models/shelf.dart';
import 'package:paladin/utils/normalised.dart';

enum CollectionType { AUTHOR, BOOK, SERIES, TAG, CURRENT, RANDOM, SETTINGS, APPS}

@immutable
class Collection {
  final CollectionType type;
  final int count;
  final String query;
  final List<dynamic>? queryArgs;

  static String collectionType(CollectionType type) => switch (type) {
    CollectionType.CURRENT  => 'Currently Reading',
    CollectionType.RANDOM   => 'Random Shelf',
    CollectionType.AUTHOR   => 'Authors',
    CollectionType.SERIES   => 'Series',
    CollectionType.BOOK     => 'Books',
    CollectionType.TAG      => 'Tags',
    CollectionType.SETTINGS => 'Settings',
    CollectionType.APPS     => 'Applications'
  };

  const Collection({ required this.type, required this.query, this.queryArgs, this.count = 0});

  Collection copyWith({CollectionType? type, String? query, List<dynamic>? queryArgs, int? count}) {
    return Collection(
      type: type ?? this.type,
      query: query ?? this.query,
      queryArgs: queryArgs ?? this.queryArgs,
      count: count ?? this.count,
    );
  }

  String getLabel() {
    return switch (type) {
      CollectionType.CURRENT => collectionType(type),
      CollectionType.RANDOM  => collectionType(type),
      _ => Shelf.shelfNeedsName(type) ? queryArgs?.first.contains(',') ? getNormalisedString(queryArgs?.first!) : queryArgs?.first : queryArgs?.first,
    };
  }

  String getNameNormalised() {
    return getLabel();
  }

  @override
  String toString() {
    return 'CollectionType: $type with "$query" and args: $queryArgs';
  }
}