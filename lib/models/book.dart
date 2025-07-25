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
  String uuid;
  int? added;
  List<Author>? authors; // Only nullable because getting authors from DB is a two step process.
  String description;
  String mimeType;
  String path;
  int lastModified;
  int? lastRead;
  int rating;
  int readStatus;
  Series? series;
  double? seriesIndex;
  List<Tag>? tags;
  String title;

  Book({
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
    required this.title}) : super(type: CollectionType.BOOK, query: booksQuery, count: 1);


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
    List<Author> authors = [Author(name: jsonBook.Author)];
    Book book = Book(
      uuid: jsonBook.UUID,
      authors: authors,
      description: jsonBook.Blurb,
      lastModified: jsonBook.Last_modified ?? 0,
      lastRead: jsonBook.Last_Read,
      rating: jsonBook.Rating ?? 0,
      readStatus: jsonBook.Is_read ? 1 : 0,
      series: jsonBook.Series.isNotEmpty ? Series(series: jsonBook.Series) : null,
      seriesIndex: jsonBook.Series.isNotEmpty ? jsonBook.Series_index : null,
      tags: jsonBook.Tags!.map((element) => Tag(tag: element)).toList(),
      title: jsonBook.Title,
      mimeType: 'application/epub+zip',
      path: await getBookPath(authors: authors, uuid: jsonBook.UUID),
    );

    return book;
  }

  static Future<Book> fromMap(LibraryDB db, Map<String, dynamic> bookMap) async {
    Book book = Book(
      uuid: bookMap['uuid'],
      added: bookMap['added'],
      description: bookMap['description'],
      path: bookMap['path'],
      mimeType: bookMap['mimeType'],
      lastModified: bookMap['lastModified'],
      lastRead: bookMap['lastRead'],
      rating: bookMap['rating'],
      readStatus: bookMap['readStatus'],
      seriesIndex: bookMap['seriesIndex'],
      title: bookMap['title'],
    );

    if (bookMap.containsKey('series') && bookMap['series'] != null) {
      book.series = await Series.getSeries(db, bookMap['series']);
    }
    book.tags = await Tag.getTags(db, book.uuid);
    book.authors = await Author.getAuthors(db, book.uuid);

    return book;
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