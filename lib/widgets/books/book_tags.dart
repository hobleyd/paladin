import 'package:dartlin/collections.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../screens/book_list.dart';

class BookTags extends ConsumerWidget {
  final Book book;

  const BookTags({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RichText(
      text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: book.tags
                  ?.mapIndexed(
                    (i, e) => TextSpan(
                      text: '${e.tag}${i < book.tags!.length - 1 && i < book.tags!.length ? ', ' : ''}',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: e)),);
                        },
                    ),
                  ).toList() ?? []
      ),
    );
  }
}