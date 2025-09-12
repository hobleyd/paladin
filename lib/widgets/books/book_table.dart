import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/collection_list_repository.dart';
import 'package:paladin/widgets/books/authors.dart';
import 'package:paladin/widgets/books/book_title.dart';
import 'package:paladin/widgets/books/last_read.dart';
import 'package:paladin/widgets/home/fatal_error.dart';

import '../../models/book.dart';
import '../../models/collection.dart';
import 'book_tile.dart';

class BookTable extends ConsumerWidget {
  final Collection collection;

  const BookTable({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var bookListAsync = ref.watch(collectionListRepositoryProvider(collection));
    return bookListAsync.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Collection> bookList) {
      return Padding(padding: EdgeInsetsGeometry.only(left: 10, right: 10), child: Table(
        children: [
          for (var collection in bookList) TableRow(
            decoration: BoxDecoration(color: bookList.indexOf(collection) % 2 == 0 ? Colors.grey.shade300 : Colors.grey.shade200,),
            children: [
            TableCell(child: BookTitle(bookUuid: (collection as Book).uuid)),
            TableCell(child: Authors(bookUuid: (collection as Book).uuid)),
            TableCell(child: LastRead(bookUuid: (collection as Book).uuid)),
          ],
          ),
        ],
      ),
      );
    });
  }
}