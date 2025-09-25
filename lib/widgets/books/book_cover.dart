import 'dart:io';

import 'package:color_filter_extension/color_filter_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../providers/book_details.dart';
import '../../providers/cached_cover.dart';
import '../home/fatal_error.dart';

class BookCover extends ConsumerWidget {
  final String bookUuid;

  const BookCover({super.key, required this.bookUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorFilter brightnessFilter = ColorFilterExt.brightness(Platform.isAndroid ? 0.7 : 0.3);
    Book? book = ref.watch(bookDetailsProvider(bookUuid));

    if (book == null) {
      return const Text('');
    }

    var coverAsync = ref.watch(cachedCoverProvider(book));
    return coverAsync.when(
        error: (error, stackTrace) {
          return FatalError(error: error.toString(), trace: stackTrace);
        },
        loading: () {
          return const Text('');
        },
        data: (Image cover) {
          return ColorFiltered(
            colorFilter: brightnessFilter,
            child: book.lastRead != null && book.lastRead! > 0
              ? cover
              : Stack(
                  alignment: AlignmentGeometry.topRight,
                  children: [
                    cover,
                    Image.asset('assets/new.png', fit: BoxFit.cover, height: 15),
                  ],
          ),
          );
        });
  }
}