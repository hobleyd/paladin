import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../providers/currently_reading_book.dart';
import '../books/book_tile.dart';
import 'fatal_error.dart';
import 'initial_instructions.dart';

class CurrentlyReading extends ConsumerWidget {
  final int shelfId;

  const CurrentlyReading({super.key, required this.shelfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentlyReadingAsync = ref.watch(currentlyReadingBookProvider);

    return currentlyReadingAsync.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (Book? book) {
      return book != null
          ? Expanded(
              child: BookTile(
                book: book,
                showMenu: true,
              ),
            )
          : const InitialInstructions();
    });
  }
}