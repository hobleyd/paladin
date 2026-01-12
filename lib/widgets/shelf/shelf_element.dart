import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../books/book_cover.dart';

class ShelfElement extends ConsumerWidget {
  final String bookUuid;
  final AutoSizeGroup shelfTitleGroup;
  final String title;

  const ShelfElement({super.key, required this.bookUuid, required this.shelfTitleGroup, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(child: BookCover(bookUuid: bookUuid)),
          const SizedBox(height: 3),
          SizedBox(
            width: 80,
            child: AutoSizeText(
              '$title\n', // the \n ensures that all titles are 2 lines which ensures the Book Covers are all identically sized in height.
              group: shelfTitleGroup,
              textAlign: TextAlign.center,
              maxLines: 2,
              minFontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}