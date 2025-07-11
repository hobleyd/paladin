import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../providers/cached_cover.dart';
import '../../screens/backcover.dart';
import '../menu/paladin_menu.dart';
import 'authors.dart';
import 'blurb.dart';
import 'book_series.dart';
import 'book_title.dart';
import 'last_read.dart';

class BookTile extends ConsumerWidget {
  final Book book;
  final bool showMenu;

  const BookTile({super.key, required this.book, required this.showMenu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var coverAsync = ref.watch(cachedCoverProvider(book));

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BackCover(book: book)));
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 6.0, right: 8.0, top: 4.0, bottom: 2.0),
            child: coverAsync.value,
          ),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                  child: Center(
                    child: Column(
                      children: [
                        BookTitle(book: book,),
                        const SizedBox(height: 3),
                        if (book.series != null) ...[
                          BookSeries(book: book),
                          const SizedBox(height: 3),
                        ],
                        Authors(book: book),
                        const SizedBox(height: 6),
                        Blurb(book: book),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      showMenu ? PaladinMenu() : const Text(''),
                      LastRead(book: book),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
