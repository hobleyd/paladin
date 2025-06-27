import 'package:dartlin/collections.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../screens/book_list.dart';

class Authors extends ConsumerWidget {
  final Book book;

  const Authors({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RichText(
        text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge,
            children: book.authors
                ?.mapIndexed((i, e) =>
                TextSpan(
                    text: '${e.name}${i < book.authors!.length - 1 && i < book.authors!.length ? ', ' : ''}',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BookList(collection: e.getBookCollection()!)),
                        );
                      },
                ),
                ).toList() ?? [],
        ),
    );
  }
}