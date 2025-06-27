import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/book.dart';

class LastRead extends ConsumerWidget {
  final Book book;

  const LastRead({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (book.lastRead != null && book.lastRead! > 0) {
      final DateTime lastRead = DateTime.fromMillisecondsSinceEpoch(book.lastRead! * 1000);
      final String formattedDate = DateFormat('MMMM d, y').format(lastRead);
      return Text('Last read: $formattedDate', style: Theme.of(context).textTheme.bodySmall);
    } else {
      return Text('Not (yet) read!', style: Theme.of(context).textTheme.bodySmall);
    }
  }
}