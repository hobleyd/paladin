import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../providers/cached_cover.dart';
import '../home/fatal_error.dart';

class BookCover extends ConsumerWidget {
  final Book book;

  const BookCover({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var coverAsync = ref.watch(cachedCoverProvider(book));

    return coverAsync.when(
        error: (error, stackTrace) {
          return FatalError(error: error.toString(), trace: stackTrace);
        },
        loading: () {
          return const Text('');
        },
        data: (Image cover) {
          return book.lastRead != null && book.lastRead! > 0
              ? cover
              : Stack(
                  alignment: AlignmentGeometry.topRight,
                  children: [
                    cover,
                    Image.asset('assets/new.png', fit: BoxFit.cover, height: 15),
                  ],
          );
        });
  }
}