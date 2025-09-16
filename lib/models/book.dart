import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../database/library_db.dart';
import '../utils/application_path.dart';
import 'author.dart';
import 'collection.dart';
import 'series.dart';
import 'tag.dart';

part 'book.g.dart';

@immutable
@JsonSerializable()
class Book extends Collection {
  static const String booksQuery = 'select * from books where title like ? order by added desc;';

  @JsonKey(name: 'UUID')
  final String uuid;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? added;

  @JsonKey(name: 'Author')
  final List<Author> authors;

  @JsonKey(name: 'Blurb')
  final String description;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String mimeType = 'application/epub+zip';

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String path;

  @JsonKey(name: 'Last_modified')
  final int lastModified;

  @JsonKey(name: 'Last_read')
  final int? lastRead;

  @JsonKey(name: 'Rating')
  final int rating;

  @JsonKey(name: 'Is_read')
  final int readStatus;

  @JsonKey(name: 'Series')
  final Series? series;

  @JsonKey(name: 'Series_index')
  final double? seriesIndex;

  @JsonKey(name: 'Tags', defaultValue: <Tag>[])
  final List<Tag> tags;

  @JsonKey(name: 'Title')
  final String title;

  String get authorNames => authors.join();

  const Book({
    required this.uuid,
    this.added,
    required this.authors,
    required this.description,
    required this.lastModified,
    this.lastRead,
    this.path = '',
    required this.rating,
    required this.readStatus,
    this.series,
    this.seriesIndex,
    required this.tags,
    required this.title}) : super(type: CollectionType.BOOK, query: booksQuery,);

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);

  Book copyBookWith({String? uuid, int? added, int? lastRead, int? rating, int? readStatus, Series? series}) {
    return Book(
      uuid:         uuid ?? this.uuid,
      added:        added ?? this.added,
      authors:      authors,
      description:  description,
      path:         path,
      lastModified: lastModified,
      lastRead:     lastRead ?? this.lastRead,
      rating:       rating ?? this.rating,
      readStatus:   readStatus ?? this.readStatus,
      series:       series ?? this.series,
      seriesIndex:  seriesIndex,
      tags:         tags,
      title:        title,
    );
  }

  static Future<String> getBookPath({ required List<Author> authors, required String uuid }) async {
    String path='';

    // TODO: decide if this is the correct folder on Android; might need to sit in External Storage?
    if (!kIsWeb) {
      path = await getApplicationPath();
    }
    path = '$path/books/${authors[0].name[0]}/$uuid.epub';

    return path;
  }

  static Future<Book> fromMap(LibraryDB db, Map<String, dynamic> bookMap) async {
    List<Author> authors = await Author.getAuthors(db, bookMap['uuid']);
    List<Tag> tags = await Tag.getTags(db, bookMap['uuid']);

    Series? series;
    if (bookMap.containsKey('series') && bookMap['series'] != null) {
      series = await Series.getSeries(db, bookMap['series']);
    }

    return Book(
      uuid:         bookMap['uuid'],
      added:        bookMap['added'],
      authors:      authors,
      description:  bookMap['description'] ?? "",
      path:         bookMap['path'],
      lastModified: bookMap['lastModified'],
      lastRead:     bookMap['lastRead'],
      rating:       bookMap['rating'],
      readStatus:   bookMap['readStatus'],
      series:       series,
      seriesIndex:  bookMap['seriesIndex'],
      tags:         tags,
      title:        bookMap['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'added': added,
      'description': description,
      'path': path,
      'mimeType': mimeType,
      'lastModified': lastModified,
      'lastRead': lastRead,
      'rating': rating,
      'readStatus': readStatus,
      'series': series?.id,
      'seriesIndex': seriesIndex,
      'title': title,
    };
  }

  @override
  String toString() {
    return '$title (#$seriesIndex of ${series?.getNameNormalised()})';
  }
}