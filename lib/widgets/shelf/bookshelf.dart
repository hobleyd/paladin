import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/shelf_repository.dart';

import '../../models/shelf.dart';
import '../home/fatal_error.dart';
import 'books_on_shelf.dart';

class BookShelf extends ConsumerWidget {
  final int shelfId;

  const BookShelf({super.key, required this.shelfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var bookListAsync = ref.watch(shelfRepositoryProvider(shelfId));

    return bookListAsync.when(
      error: (error, stackTrace) {
        return FatalError(error: error.toString(), trace: stackTrace);
      },
      loading: () {
        return const Text('');
      },
      data: (Shelf bookShelf) {
        return BooksOnShelf(shelf: bookShelf);
      },
    );
  }
}
