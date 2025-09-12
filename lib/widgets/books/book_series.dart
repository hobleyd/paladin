import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/navigator_stack.dart';

import '../../models/book.dart';
import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../providers/book_provider.dart';
import '../../screens/book_list.dart';

class BookSeries extends ConsumerWidget {
  final String bookUuid;

  const BookSeries({super.key, required this.bookUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Book? book = ref.watch(bookProviderProvider(bookUuid));
    if (book == null) {
      return const Text('');
    }

    return book.series != null
        ? RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(
                  text: book.series!.getNameNormalised(),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                    ref.read(navigatorStackProvider.notifier).push(
                      context,
                      "books_by_series",
                      MaterialPageRoute(
                          builder: (context) => BookList(
                            collection: Collection(type: CollectionType.BOOK, query: Shelf.shelfQuery[CollectionType.SERIES]!, queryArgs: [book.series!.series],),
                          ),
                        ),
                      );
                    },
                ),
                TextSpan(text: ' #${book.seriesIndex}'),
              ],
            ),
          )
        : const SizedBox(height: 0);
  }
}