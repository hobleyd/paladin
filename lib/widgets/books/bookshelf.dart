import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../providers/cached_cover.dart';
import '../../repositories/shelf_repository.dart';

class BookShelf extends ConsumerStatefulWidget {
  final Shelf shelf;

  const BookShelf({super.key, required this.shelf});

  @override
  ConsumerState<BookShelf> createState() => _BookShelf();
}

class _BookShelf extends ConsumerState<BookShelf> {
  Shelf get shelf => widget.shelf;

  @override
  Widget build(BuildContext context) {
    var bookListAsync = ref.watch(ShelfRepositoryProvider(shelf.collection));
    return bookListAsync.when(error: (error, stackTrace) {
      return const Text("You have no Books? What's wrong with you?");
    }, loading: () {
      return const Text('');
    }, data: (List<Book> bookShelf) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Text(
              '${shelf.collection.getType()} (${bookShelf.length})',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: bookShelf.length,
              itemBuilder: (context, index) {
                Book book = bookShelf[index];
                String title = book.title.split(':').first;
                var coverAsync = ref.watch(cachedCoverProvider(book));

                return InkWell(
                  onTap: () => book.readBook(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(child: coverAsync.value ?? Image.asset('assets/generic_book_cover.png', fit: BoxFit.cover)),
                        const SizedBox(height: 3),
                        SizedBox(
                          width: 80,
                          child: AutoSizeText(
                            title,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
            ),
          ),
        ],
      );
    });
  }
}