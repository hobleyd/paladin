import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calibre_book_count.dart';
import '../../utils/date.dart';

class BookTable extends ConsumerWidget {
  final String label;
  final Future<CalibreBookCount>? future;

  const BookTable({super.key, required this.label, required this.future});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext ctx, AsyncSnapshot<CalibreBookCount> bookCount) {
          int count = bookCount.data == null ? 0 : bookCount.data!.count;
          return Column(
            children: [
              Text('There are $count $label', style: Theme.of(context).textTheme.labelMedium),
              const Divider(color: Colors.black, thickness: 1),
              if (bookCount.data != null) Table(
                children: [
                  for (var book in bookCount.data!.books) TableRow(
                    decoration: BoxDecoration(color: bookCount.data!.books.indexOf(book) % 2 == 0 ? Colors.grey.shade300 : Colors.grey.shade200,),
                    children: [
                      TableCell(child: Text(book.title, style: Theme.of(context).textTheme.bodySmall)),
                      TableCell(child: Text(book.author, style: Theme.of(context).textTheme.bodySmall)),
                      TableCell(child: Text(getFormattedDateTime(book.lastModified), style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ],
              ),
            ],
          );
        });
  }
}