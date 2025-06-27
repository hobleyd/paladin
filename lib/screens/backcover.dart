import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../providers/cached_cover.dart';
import '../widgets/books/authors.dart';
import '../widgets/books/blurb.dart';
import '../widgets/books/book_series.dart';
import '../widgets/books/book_tags.dart';

class BackCover extends ConsumerWidget {
  final Book book;
  const BackCover({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                ref.watch(cachedCoverProvider(book)).value ?? Image.asset('assets/generic_book_cover.png', fit: BoxFit.cover),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(book.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                      BookSeries(book: book),
                      Authors(book: book),
                      BookTags(book: book),
                      RatingBar.builder(
                          direction: Axis.horizontal,
                          glow: false,
                          itemCount: 5,
                          itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.black,
                              ),
                          initialRating: book.rating.toDouble(),
                          itemSize: 24,
                          tapOnlyMode: true,
                          onRatingUpdate: (rating) {
                            // TODO: Ensure the book gets updated when we set the rating;
                            book.setRating(ref, rating.floor());
                          },
                      ),
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
    );
  }
}
