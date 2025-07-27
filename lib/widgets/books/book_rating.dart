import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';

class BookRating extends ConsumerWidget {
  final Book book;

  const BookRating({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RatingBar.builder(
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
    );
  }
}