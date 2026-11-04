import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calibre_book_count.dart';
import '../../models/calibre_update_list.dart';
import '../../utils/date.dart';

class BookTable extends ConsumerWidget {
  final String label;
  final Future<CalibreBookCount>? future;

  static const double _columnGap = 8.0;

  const BookTable({super.key, required this.label, required this.future});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext ctx, AsyncSnapshot<CalibreBookCount> bookCount) {
        int count = bookCount.data == null ? 0 : bookCount.data!.count;
        List<CalibreUpdateList> books = bookCount.data == null ? [] : bookCount.data!.books;
        TextStyle? style = Theme.of(context).textTheme.bodySmall;

        // Each row as [title, author, date].
        List<List<String>> rows = [
          for (var book in books) [book.title, book.author, getFormattedDateTime(book.lastModified)],
        ];

        return Column(
          children: [
            Text('There are $count $label', style: Theme.of(context).textTheme.labelMedium),
            const Divider(color: Colors.black, thickness: 1),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    child: _fitsOnOneLine(context, rows, style, constraints.maxWidth)
                        ? _singleLineTable(rows, style)
                        : _stackedList(rows, style),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Color _rowColour(int index) => index % 2 == 0 ? Colors.grey.shade300 : Colors.grey.shade200;

  // True if every row's title, author and date fit side by side on one line, using the widest value in each column.
  bool _fitsOnOneLine(BuildContext context, List<List<String>> rows, TextStyle? style, double maxWidth) {
    List<double> columnWidths = [0, 0, 0];
    for (var row in rows) {
      for (int column = 0; column < row.length; column++) {
        TextPainter painter = TextPainter(
          text: TextSpan(text: row[column], style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        if (painter.width > columnWidths[column]) {
          columnWidths[column] = painter.width;
        }
        painter.dispose();
      }
    }

    return columnWidths.reduce((a, b) => a + b) + 2 * _columnGap <= maxWidth;
  }

  Widget _singleLineTable(List<List<String>> rows, TextStyle? style) {
    return Table(
      columnWidths: const {0: FlexColumnWidth(), 1: IntrinsicColumnWidth(), 2: IntrinsicColumnWidth()},
      children: [
        for (int i = 0; i < rows.length; i++)
          TableRow(
            decoration: BoxDecoration(color: _rowColour(i)),
            children: [
              TableCell(child: Padding(padding: const EdgeInsets.only(right: _columnGap), child: Text(rows[i][0], style: style))),
              TableCell(child: Padding(padding: const EdgeInsets.only(right: _columnGap), child: Text(rows[i][1], style: style))),
              TableCell(child: Text(rows[i][2], style: style)),
            ],
          ),
      ],
    );
  }

  Widget _stackedList(List<List<String>> rows, TextStyle? style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < rows.length; i++)
          Container(
            color: _rowColour(i),
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(rows[i][0], style: style),
                Text(rows[i][1], style: style, textAlign: TextAlign.right),
                Text(rows[i][2], style: style, textAlign: TextAlign.right),
              ],
            ),
          ),
      ],
    );
  }
}
