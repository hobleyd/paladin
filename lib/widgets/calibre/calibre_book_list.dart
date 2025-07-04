import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/json_book.dart';
import '../../providers/calibre_book_provider.dart';

class CalibreBookList extends ConsumerWidget {
  final BooksType bookType;

  const CalibreBookList({super.key, required this.bookType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScrollController scrollController = ScrollController();

    List<JSONBook> books = ref.read(calibreBookProvider(bookType));
    return Scrollbar(
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        child: ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            return ListTile(subtitle: Text(books[index].Author), title: Text(books[index].Title));
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
        ),
      ),
    );
  }
}