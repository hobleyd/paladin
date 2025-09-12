import 'package:dartlin/collections.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/navigator_stack.dart';

import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../screens/book_list.dart';

class BookTags extends ConsumerWidget {
  final String bookUuid;

  const BookTags({super.key, required this.bookUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Book? book = ref.watch(bookProviderProvider(bookUuid));
    if (book == null) {
      return const Text('');
    }

    return RichText(
      text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: book.tags
                  ?.mapIndexed(
                    (i, e) => TextSpan(
                      text: '${e.tag}${i < book.tags!.length - 1 && i < book.tags!.length ? ', ' : ''}',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                        ref.read(navigatorStackProvider.notifier).push(context, "tags", MaterialPageRoute(builder: (context) => BookList(collection: e)),);
                        },
                    ),
                  ).toList() ?? []
      ),
    );
  }
}