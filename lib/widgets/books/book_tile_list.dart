import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/collection_repository.dart';
import 'package:paladin/widgets/home/fatal_error.dart';

import '../../models/book.dart';
import '../../models/collection.dart';
import 'book_tile.dart';

class BookTileList extends ConsumerWidget {
  final Collection collection;

  const BookTileList({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var bookListAsync = ref.watch(collectionRepositoryProvider(collection));
    return bookListAsync.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Collection> bookList) {
      return ListView.builder(
          itemCount: bookList.length,
          itemBuilder: (context, index) {
            return bookList.isNotEmpty
                ? Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 6,
                          child: BookTile(
                            book: bookList[index] as Book,
                            showMenu: false,
                          )),
                      const Divider(color: Colors.black, thickness: 1),
                    ],
                  )
                : const Text(
                    "The library elves simply can't find any books in this collection!",
                    textAlign: TextAlign.center,
                  );
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: true);
    });
  }
}