import 'package:dartlin/collections.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/author.dart';
import '../../models/book.dart';
import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../screens/book_list.dart';

class Authors extends ConsumerWidget {
  final Book book;

  const Authors({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RichText(
        text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: book.authors
                ?.mapIndexed((i, e) =>
                TextSpan(
                    text: '${e.getNameNormalised()}${i < book.authors!.length - 1 && i < book.authors!.length ? ', ' : ''}',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _showAuthorBooks(context, e)
                ),
                ).toList() ?? [],
        ),
    );
  }

  void _showAuthorBooks(BuildContext context, Author author) {
    final Collection authorBooks = Collection(
      type: CollectionType.BOOK,
      query: Shelf.shelfQuery[CollectionType.AUTHOR]!,
      queryArgs: [author.name],
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: authorBooks)),);
  }
}