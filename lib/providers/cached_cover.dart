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
  @override
  Future<Image> build(Book book) async {
    File cover = await _getCoverPath();
    if (!cover.existsSync()) {
      cacheCover();
    }

    // Note that if the epub doesn't have a cover, we can't cache and we can still be left without one, here.
    return cover.existsSync()
        ? Image.file(cover, fit: BoxFit.cover)
        : Image.asset('assets/generic_book_cover.png', fit: BoxFit.cover, height: 200);
  }

  Future<void> cacheCover() async {
    File bookPath = File(book.path);
    if (bookPath.existsSync() && bookPath.statSync().size > 0) {
      Epub epubBook = Epub(bookName: book.title, bookPath: book.path, bookUUID: book.uuid, ref: ref);
      final images.Image? coverImage = epubBook.getCover();

      if (coverImage != null) {
        // TODO: need a better way of deciding the height we want to resize to.
        images.Image resizedCover = images.copyResize(coverImage, height: 200);
        File cover = await _getCoverPath();
        cover.createSync(recursive: true);
        cover.writeAsBytesSync(images.encodeJpg(resizedCover));
      }
    }
  }

  Future<File> _getCoverPath() async {
    String coverPath = await getApplicationPath();
    return File('$coverPath/covers/${book.authors[0].name[0]}/${book.uuid}.jpg');
  }
}