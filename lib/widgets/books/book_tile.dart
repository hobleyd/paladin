import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/currently_reading_book.dart';
import 'package:paladin/providers/navigator_stack.dart';
import 'package:paladin/widgets/books/book_cover.dart';

import '../../models/book.dart';
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
    return InkWell(
      onTap: () {
        if (showMenu) {
          ref.read(currentlyReadingBookProvider.notifier).readBook(book);
        } else {
          ref.read(navigatorStackProvider.notifier).push(context, "back_cover", MaterialPageRoute(builder: (context) => BackCover(book: book), settings: RouteSettings(name: "/home")));
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 6.0, right: 8.0, top: 4.0, bottom: 2.0),
            child: BookCover(book: book),
          ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: [
                      BookTitle(book: book,),
                      if (showMenu) BookSeries(book: book),
                      Authors(book: book),
                      const SizedBox(height: 3),
                      Blurb(book: book),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showMenu) PaladinMenu(),
                      if (!showMenu && book.series != null) BookSeries(book: book),
                      if (!showMenu) LastRead(book: book),
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
