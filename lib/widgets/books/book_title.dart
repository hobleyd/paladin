import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../providers/book_details.dart';

class BookTitle extends ConsumerWidget {
  final String bookUuid;

  const BookTitle({super.key, required this.bookUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Book? book = ref.watch(bookDetailsProvider(bookUuid));
    if (book == null) {
      return const Text('');
    }

    return Text(book.title, style: Theme.of(context).textTheme.labelSmall);
  }
}