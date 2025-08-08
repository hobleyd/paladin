import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/library_db.dart';
import '../repositories/books_repository.dart';
import 'author.dart';
import 'collection.dart';
import 'json_book.dart';
import 'series.dart';
import 'tag.dart';

@immutable
class Book extends Collection {
  static const String booksQuery = 'select * from books where title like ? order by added desc;';

  final String uuid;
  final int? added;
  final List<Author>? authors; // Only nullable because getting authors from DB is a two step process.
  final String description;
  final String mimeType;
  final String path;
  final int lastModified;
  final int? lastRead;
  final int rating;
  final int readStatus;
  final Series? series;
  final double? seriesIndex;
  final List<Tag>? tags;
  final String title;

  const Book({
    required this.uuid,
    this.added,
    this.authors,
    required this.description,
    required this.mimeType,
    required this.lastModified,
    this.lastRead,
    required this.path,
    required this.rating,
    required this.readStatus,
    this.series,
    this.seriesIndex,
    this.tags,
    required this.title}) : super(type: CollectionType.BOOK, query: booksQuery,);

  Book copyBookWith({String? uuid, int? added, int? lastRead, int? rating, int? readStatus, Series? series}) {
    return Book(
      uuid:         uuid ?? this.uuid,
      added:        added ?? this.added,
      authors:      authors,
      description:  description,
      mimeType:     mimeType,
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

    if (!kIsWeb) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = documentsDirectory.path;
    }
    path = '$path/books/${authors[0].name[0]}/$uuid.epub';

    return path;
  }

  Future readBook(BuildContext context, WidgetRef ref) async {
    ref.read(booksRepositoryProvider.notifier).updateBookLastReadDate(this);

    if (Platform.isAndroid || Platform.isIOS) {
      OpenFilex.open(path, type: mimeType);
    } else {
      launchUrl(Uri.file(path));
    }
  }

  Future setRating(WidgetRef ref, int rating) async {
    ref.read(booksRepositoryProvider.notifier).setRating(this, rating);
  }

  static Future<Book> fromJSON(JSONBook jsonBook) async {
    List<Author> authors = [Author(name: jsonBook.Author, queryArgs: [jsonBook.Author])];
    Book book = Book(
      uuid: jsonBook.UUID,
      authors: authors,
      description: jsonBook.Blurb,
      lastModified: jsonBook.Last_modified ?? 0,
      lastRead: jsonBook.Last_Read,
      rating: jsonBook.Rating ?? 0,
      readStatus: jsonBook.Is_read ? 1 : 0,
      series: jsonBook.Series.isNotEmpty ? Series(series: jsonBook.Series, queryArgs: [jsonBook.Series]) : null,
      seriesIndex: jsonBook.Series.isNotEmpty ? jsonBook.Series_index : null,
      tags: jsonBook.Tags!.map((element) => Tag(tag: element, queryArgs: [element])).toList(),
      title: jsonBook.Title,
      mimeType: 'application/epub+zip',
      path: await getBookPath(authors: authors, uuid: jsonBook.UUID),
    );

    return book;
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
      description:  bookMap['description'],
      path:         bookMap['path'],
      lastModified: bookMap['lastModified'],
      lastRead:     bookMap['lastRead'],
      mimeType:     bookMap['mimeType'],
      rating:       bookMap['rating'],
      readStatus:   bookMap['readStatus'],
      series:       series,
      seriesIndex:  bookMap['seriesIndex'],
      tags:         tags,
      title:        bookMap['title'],
    );
  }

  JSONBook toJSON() {
    return JSONBook(
        UUID: uuid,
        Author: authors?.join(" ") ?? "",
        Blurb: description,
        Is_read: readStatus == 1 ? true : false,
        Last_modified: lastModified,
        Last_Read: lastRead,
        Rating: rating,
        Series: series?.series ?? "",
        Series_index: seriesIndex ?? 0,
        Title: title);
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