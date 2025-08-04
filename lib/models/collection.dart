
import 'package:flutter/foundation.dart';
import 'package:paladin/utils/normalised.dart';

enum CollectionType { AUTHOR, BOOK, SERIES, TAG, CURRENT, RANDOM, SETTINGS, APPS}

/*
 * A Collection is the metadata describing a Set of books, settings, or (mobile) applications; it can be used
 * to filter down the collection of things, by a defined set of attributes: Author, Series, Tag, Title etc.
 *
 * A Collection will be displayed on a Shelf, or a specific Widget designed to show the content appropriately.
 */

@immutable
class Collection {
  final CollectionType type;
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

  const Collection({ required this.type, required this.query, this.queryArgs, });

  Collection copyWith({CollectionType? type, String? query, List<dynamic>? queryArgs, }) {
    return Collection(
      type:      type ?? this.type,
      query:     query ?? this.query,
      queryArgs: queryArgs ?? this.queryArgs,
    );
  }

  String getLabel() {
    return switch (type) {
      CollectionType.CURRENT   => collectionType(type),
      CollectionType.RANDOM    => collectionType(type),
      CollectionType.SETTINGS  => collectionType(type),
      CollectionType.APPS      => collectionType(type),
      _ => queryArgs?.first.contains(',') ? getNormalisedString(queryArgs?.first!) : queryArgs?.first,
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