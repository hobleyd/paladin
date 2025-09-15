import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/book_provider.dart';
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
  final String bookUuid;
  final bool showMenu;

  const BookTile({super.key, required this.bookUuid, required this.showMenu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Book? book = ref.watch(bookProviderProvider(bookUuid));
    if (book == null) {
      return const Text('');
    }

    return InkWell(
      onTap: () {
        if (showMenu) {
          ref.read(bookProviderProvider(bookUuid).notifier).readBook();
        } else {
          ref.read(navigatorStackProvider.notifier).push(context, "back_cover", MaterialPageRoute(builder: (context) => BackCover(bookUuid: bookUuid), settings: RouteSettings(name: "/home")));
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 6.0, right: 8.0, top: 4.0, bottom: 2.0),
            child: BookCover(bookUuid: bookUuid),
          ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: [
                      BookTitle(bookUuid: bookUuid,),
                      if (showMenu) BookSeries(bookUuid: bookUuid),
                      Authors(bookUuid: bookUuid),
                      const SizedBox(height: 3),
                      Blurb(bookUuid: bookUuid),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showMenu) PaladinMenu(),
                      if (!showMenu && book.series != null) BookSeries(bookUuid: bookUuid),
                      if (!showMenu) LastRead(bookUuid: bookUuid),
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
