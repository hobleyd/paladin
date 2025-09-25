import 'package:dartlin/collections.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/book_details.dart';
import 'package:paladin/providers/navigator_stack.dart';

import '../../models/author.dart';
import '../../models/book.dart';
import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../screens/book_list.dart';

class Authors extends ConsumerWidget {
  final String bookUuid;

  const Authors({super.key, required this.bookUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Book? book = ref.watch(bookDetailsProvider(bookUuid));
    if (book == null) {
      return const Text('');
    }

    return RichText(
        text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: book.authors
                .mapIndexed((i, e) =>
                TextSpan(
                    text: '${e.getNameNormalised()}${i < book.authors.length - 1 && i < book.authors.length ? ', ' : ''}',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _showAuthorBooks(context, ref, e)
                ),
                ).toList(),
        ),
    );
  }

  void _showAuthorBooks(BuildContext context, WidgetRef ref, Author author) {
    final Collection authorBooks = Collection(
      type: CollectionType.BOOK,
      query: Shelf.shelfQuery[CollectionType.AUTHOR]!,
      queryArgs: [author.name],
    );

    ref.read(navigatorStackProvider.notifier).push(context, "books_by_author", MaterialPageRoute(builder: (context) => BookList(collection: authorBooks)),);
  }
}