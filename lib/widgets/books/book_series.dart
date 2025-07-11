import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../screens/book_list.dart';

class BookSeries extends ConsumerWidget {
  final Book book;

  const BookSeries({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return book.series != null
        ? RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.labelSmall /*bodyLarge?*/,
              children: [
                TextSpan(
                  text: book.series!.getSeriesNameNormalised(),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookList(collection: book.series!)),
                      );
                    },
                ),
                TextSpan(text: ' #${book.seriesIndex}'),
              ],
            ),
          )
        : const Text('');
  }
}