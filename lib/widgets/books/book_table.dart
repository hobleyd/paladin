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
            Table(
              children: [
                // TODO: I'd prefer this to be scrollable, but I can't figure that out! So manage it manually.
                for (int i = 0; i < (count > 20 ? 20 : count); i++)
                  TableRow(
                    decoration: BoxDecoration(color: i % 2 == 0 ? Colors.grey.shade300 : Colors.grey.shade200,),
                    children: [
                      TableCell(child: Text(bookCount.data!.books[i].title, style: Theme.of(context).textTheme.bodySmall)),
                      TableCell(child: Text(bookCount.data!.books[i].author, style: Theme.of(context).textTheme.bodySmall)),
                      TableCell(child: Text(getFormattedDateTime(bookCount.data!.books[i].lastModified), style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
              ],
            ),
            if (count > 25) Text('...'),
          ],
        );
      },
    );
  }
}
