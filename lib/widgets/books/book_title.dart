import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';

class BookTitle extends ConsumerWidget {
  final Book book;

  const BookTitle({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(book.title, style: Theme.of(context).textTheme.labelSmall);
  }
}