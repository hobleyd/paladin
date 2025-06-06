import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as images;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/library_db.dart';
import 'author.dart';
import 'collection.dart';
import 'json_book.dart';
import 'series.dart';
import 'tag.dart';

class Book extends Collection {
  static const String booksQuery = 'select * from books where title like ? order by added desc;';
  String uuid;
  int? added;
  List<Author>? authors; // Only nullable because getting authors from DB is a two step process.
  String? description;
  String? mimeType;
  String? path;
  int? lastModified;
  int? lastRead;
  int? rating;
  int? readStatus;
  Series? series;
  double? seriesIndex;
  List<Tag>? tags;
  String title;
  File? cachedCover;

  Book({
    required this.uuid,
    this.added,
    this.authors,
    this.description,
    this.mimeType,
    this.path,
    this.lastModified,
    this.lastRead,
    this.rating,
    this.readStatus,
    this.series,
    this.seriesIndex,
    this.tags,
    required this.title}) : super(type: CollectionType.BOOK);

  Future cacheCover() async {
    if (path != null) {
      File book = File(path!);

      if (book.existsSync() && book.statSync().size > 0) {
        if (cachedCover == null) {
          await getCoverPath();
        }

        if (!cachedCover!.existsSync()) {
          EpubBookRef bookRef = await EpubReader.openBook(book.readAsBytes());
          final images.Image? coverImage = await bookRef.readCover();

          if (coverImage != null) {
            // TODO: need a better way of deciding the height we want to resize to.
            images.Image resizedCover = images.copyResize(coverImage, height: 200);
            cachedCover!.createSync(recursive: true);
            await cachedCover!.writeAsBytes(images.encodeJpg(resizedCover));
          }
        }
      }
    }
  }

  Future<void> getCoverPath() async {
    if (cachedCover == null) {
      String coverPath = '';
      if (!kIsWeb) {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        coverPath = documentsDirectory.path;
      }

      cachedCover = File('$coverPath/covers/${authors![0].name[0]}/$uuid.jpg');
    }
  }

  Future<String> getBookPath() async {
    if (!kIsWeb) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = documentsDirectory.path;
    }
    path = '$path/books/${authors![0].name[0]}/$uuid.epub';

    return path!;
  }

  Future readBook(BuildContext context) async {
    final LibraryDB library = Provider.of<LibraryDB>(context, listen: false);
    library.updateBook(this);
    if (Platform.isAndroid || Platform.isIOS) {
      OpenFilex.open(path!, type: mimeType);
    } else {
      launchUrl(Uri.file(path!));
    }
  }

  Future setRating(BuildContext context, int newRating) async {
    final LibraryDB library = Provider.of<LibraryDB>(context, listen: false);
    rating = newRating;
    library.updateBook(this);
  }

  static Future<Book> fromJSON(JSONBook jsonBook) async {
    Book book = Book(
      uuid: jsonBook.UUID,
      authors: [Author(name: jsonBook.Author)],
      description: jsonBook.Blurb,
      lastModified: jsonBook.Last_modified,
      lastRead: jsonBook.Last_Read,
      rating: jsonBook.Rating,
      readStatus: jsonBook.Is_read ? 1 : 0,
      series: jsonBook.Series.isNotEmpty ? Series(series: jsonBook.Series) : null,
      seriesIndex: jsonBook.Series.isNotEmpty ? jsonBook.Series_index : null,
      tags: jsonBook.Tags!.map((element) => Tag(tag: element)).toList(),
      title: jsonBook.Title,
      mimeType: 'application/epub+zip',
    );

    await book.getBookPath();
    return book;
  }

  static Future<Book> fromMap(Database db, Map<String, dynamic> bookMap) async {
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
    await book.getCoverPath();

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
    return '$title (#$seriesIndex of ${series?.series})';
  }
}