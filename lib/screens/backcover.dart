import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../widgets/books/authors.dart';
import '../widgets/books/blurb.dart';
import '../widgets/books/book_cover.dart';
import '../widgets/books/book_rating.dart';
import '../widgets/books/book_series.dart';
import '../widgets/books/book_tags.dart';

class BackCover extends ConsumerWidget {
  final Book book;
  const BackCover({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 10),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  BookCover(book: book),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(book.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (book.series != null )BookSeries(book: book),
                        Authors(book: book),
                        BookTags(book: book),
                        BookRating(book: book),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.black, thickness: 1),
            Blurb(book: book),
            const Divider(color: Colors.black, thickness: 1),
            ElevatedButton(onPressed: () => book.readBook(context, ref), child: const Text('Read Book')),
          ],
        ),
      ),
    );
  }
}
