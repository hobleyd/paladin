import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/shelf_repository.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/book.dart';
import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../providers/cached_cover.dart';
import '../../repositories/shelf_books_repository.dart';
import '../../screens/backcover.dart';
import '../../utils/iterable.dart';
import '../home/fatal_error.dart';
import 'books_on_shelf.dart';

class BookShelf extends ConsumerStatefulWidget {
  final int shelfId;

  const BookShelf({super.key, required this.shelfId});

  @override
  ConsumerState<BookShelf> createState() => _BookShelf();
}

class _BookShelf extends ConsumerState<BookShelf> {
  int get shelfId => widget.shelfId;
  Set<int> visibleBooks = {};

  @override
  Widget build(BuildContext context) {
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
