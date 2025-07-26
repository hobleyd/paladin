import 'dart:io';

import 'package:epubx/epubx.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as images;
import 'package:paladin/utils/application_path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/book.dart';

part 'cached_cover.g.dart';

@riverpod
class CachedCover extends _$CachedCover {
  late File _cover;

  @override
  Future<Image> build(Book book) async {
    String coverPath = await getApplicationPath();

    _cover = File('$coverPath/covers/${book.authors![0].name[0]}/${book.uuid}.jpg');

    if (!_cover.existsSync()) {
      await cacheCover();
    }

    // Note that if the epub doesn't have a cover, we can still be left without one, here.
    return _cover.existsSync()
        ? Image.file(_cover, fit: BoxFit.cover)
        : Image.asset('assets/generic_book_cover.png', fit: BoxFit.cover);  }

  Future cacheCover() async {
    File bookPath = File(book.path);

    if (bookPath.existsSync() && bookPath.statSync().size > 0) {
      EpubBookRef bookRef = await EpubReader.openBook(bookPath.readAsBytes());
      final images.Image? coverImage = await bookRef.readCover();

      if (coverImage != null) {
        // TODO: need a better way of deciding the height we want to resize to.
        images.Image resizedCover = images.copyResize(coverImage, height: 200);
        _cover.createSync(recursive: true);
        await _cover.writeAsBytes(images.encodeJpg(resizedCover));
      }
    }
  }
}