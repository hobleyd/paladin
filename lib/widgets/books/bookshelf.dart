import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/book.dart';
import '../../models/shelf.dart';
import '../../providers/cached_cover.dart';
import '../../repositories/shelf_repository.dart';
import '../../utils/iterable.dart';
import '../home/fatal_error.dart';

class BookShelf extends ConsumerStatefulWidget {
  final Shelf shelf;

  const BookShelf({super.key, required this.shelf});

  @override
  ConsumerState<BookShelf> createState() => _BookShelf();
}

class _BookShelf extends ConsumerState<BookShelf> {
  Shelf get shelf => widget.shelf;
  Set<int> visibleBooks = {};

  @override
  Widget build(BuildContext context) {
    var bookListAsync = ref.watch(ShelfRepositoryProvider(shelf.collection));
    AutoSizeGroup shelfTitleGroup = AutoSizeGroup();

    return bookListAsync.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Text('');
    }, data: (List<Book> bookShelf) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Text(
              '${shelf.collection.getNameNormalised()} (${visibleBooks.min}-${visibleBooks.max} of ${bookShelf.length})',
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

                return VisibilityDetector(
                  key: Key('${shelf.collection.getNameNormalised()}-$index'),
                  onVisibilityChanged: (visibility) => _updateVisibility(index+1, visibility.visibleFraction > 0.5),
                    child: InkWell(
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
                            '$title\n', // the \n ensures that all titles are 2 lines which ensures the Book Covers are all identically sized in height.
                            group: shelfTitleGroup,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            minFontSize: 8,
                          ),
                        ),
                      ],
                    ),
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

  void _updateVisibility(int index, bool isVisible) {
    setState(() {
      if (isVisible) {
        visibleBooks.add(index);
      } else {
        visibleBooks.remove(index);
      }
    });
  }
}