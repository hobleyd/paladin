import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/book.dart';
import '../../models/shelf.dart';
import '../../providers/book_details.dart';
import '../../providers/navigator_stack.dart';
import '../../providers/shelf_collection.dart';
import '../../repositories/shelf_books_repository.dart';
import '../../screens/backcover.dart';
import '../../utils/iterable.dart';
import '../books/book_cover.dart';
import '../home/fatal_error.dart';

class BooksOnShelf extends ConsumerStatefulWidget {
  final Shelf shelf;

  const BooksOnShelf({super.key, required this.shelf});

  @override
  ConsumerState<BooksOnShelf> createState() => _BooksOnShelf();
}

class _BooksOnShelf extends ConsumerState<BooksOnShelf> {
  Shelf get shelf => widget.shelf;
  Set<int> visibleBooks = {};

  @override
  Widget build(BuildContext context) {
    var shelfCollection = ref.watch(shelfCollectionProvider(shelf.shelfId));
    var bookListAsync = ref.watch(shelfBooksRepositoryProvider(shelfCollection!));
    AutoSizeGroup shelfTitleGroup = AutoSizeGroup();

    return bookListAsync.when(
      error: (error, stackTrace) {
        return FatalError(error: error.toString(), trace: stackTrace);
      },
      loading: () {
        return const Text('');
      },
      data: (List<String> bookShelf) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
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
                  Book? book = ref.watch(bookDetailsProvider(bookShelf[index]));
                  if (book == null) {
                    // We are using the bookProvider here to get the Book and the first time through, it will always be null.
                    // Returning an 'X' here as it could also be null if the provider is disposed of. Shouldn't be a problem
                    // from my understanding, but this will be a visual indication if it is. TODO: Remove after testing.
                    return const Text('X');
                  }
                  String title = book.title.split(':').first;

                  return VisibilityDetector(
                    key: Key('${shelf.collection.getNameNormalised()}-$index'),
                    onVisibilityChanged: (visibility) => _updateVisibility(index + 1, visibility.visibleFraction > 0.5),
                    child: InkWell(
                      onTap: () => _openBook(bookShelf[index]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Expanded(child: BookCover(bookUuid: bookShelf[index])),
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
      },
    );
  }

  void _openBook(String bookUuid) {
    ref.read(navigatorStackProvider.notifier).push(context, "back_cover", MaterialPageRoute(builder: (context) => BackCover(bookUuid: bookUuid), settings: RouteSettings(name: "/home")));
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
