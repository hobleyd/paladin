import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../providers/book_provider.dart';

class BookRating extends ConsumerWidget {
  final String bookUuid;

  const BookRating({super.key, required this.bookUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Book? book = ref.watch(bookProviderProvider(bookUuid));
    if (book == null) {
      return const Text('');
    }

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
        ref.read(bookProviderProvider(book.uuid).notifier).setRating(rating.floor());
      },
    );
  }
}