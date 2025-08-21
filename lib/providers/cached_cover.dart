import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as images;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../epub/epub_archive.dart';
import '../models/book.dart';
import '../utils/application_path.dart';

part 'cached_cover.g.dart';

@riverpod
class CachedCover extends _$CachedCover {
  late File _cover;

  @override
  Future<Image> build(Book book) async {
    String coverPath = await getApplicationPath();

    _cover = File('$coverPath/covers/${book.authors![0].name[0]}/${book.uuid}.jpg');

    if (!_cover.existsSync()) {
      cacheCover();
    }

    // Note that if the epub doesn't have a cover, we can't cache and we can still be left without one, here.
    return _cover.existsSync()
        ? Image.file(_cover, fit: BoxFit.cover)
        : Image.asset('assets/generic_book_cover.png', fit: BoxFit.cover);
  }

  void cacheCover() {
    File bookPath = File(book.path);
    if (bookPath.existsSync() && bookPath.statSync().size > 0) {
      Epub epubBook = Epub(bookName: book.title, bookPath: book.path);
      epubBook.openBook();
      final images.Image? coverImage = epubBook.getCover();

      if (coverImage != null) {
        // TODO: need a better way of deciding the height we want to resize to.
        images.Image resizedCover = images.copyResize(coverImage, height: 200);
        _cover.createSync(recursive: true);
        _cover.writeAsBytesSync(images.encodeJpg(resizedCover));
      }
    }
  }
}