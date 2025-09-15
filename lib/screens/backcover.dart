import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/navigator_stack.dart';
import '../widgets/books/authors.dart';
import '../widgets/books/blurb.dart';
import '../widgets/books/book_cover.dart';
import '../widgets/books/book_rating.dart';
import '../widgets/books/book_series.dart';
import '../widgets/books/book_tags.dart';
import '../widgets/books/book_title.dart';

class BackCover extends ConsumerWidget {
  final String bookUuid;
  const BackCover({super.key, required this.bookUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Book? book = ref.watch(bookProviderProvider(bookUuid));

    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 10),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  BookCover(bookUuid: bookUuid),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BookTitle(bookUuid: bookUuid),
                        if (book?.series != null) BookSeries(bookUuid: bookUuid),
                        Authors(bookUuid: bookUuid),
                        BookTags(bookUuid: bookUuid),
                        BookRating(bookUuid: bookUuid),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.black, thickness: 1),
            Blurb(bookUuid: bookUuid),
            const Divider(color: Colors.black, thickness: 1),
            ElevatedButton(onPressed: () => _readBook(context, ref), child: const Text('Read Book')),
          ],
        ),
      ),
    );
  }

  void _readBook(BuildContext context, WidgetRef ref) {
    ref.read(bookProviderProvider(bookUuid).notifier).readBook();
    ref.read(navigatorStackProvider.notifier).popUntil(context, "home_screen");
  }
}
