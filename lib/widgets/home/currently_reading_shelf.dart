import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../models/shelf.dart';
import '../../repositories/shelf_books_repository.dart';
import '../books/book_tile.dart';
import 'fatal_error.dart';
import 'initial_instructions.dart';

class CurrentlyReadingShelf extends ConsumerWidget {
  final Shelf currentlyReading;

  const CurrentlyReadingShelf({super.key, required this.currentlyReading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelfAsync = ref.watch(shelfBooksRepositoryProvider(currentlyReading.collection));

    return shelfAsync.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Book> books) {
      return books.isNotEmpty
          ? Expanded(
              child: BookTile(
                book: books[0],
                showMenu: true,
              ),
            )
          : const InitialInstructions();
    });
  }
}