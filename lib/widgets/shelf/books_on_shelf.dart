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
import '../home/fatal_error.dart';
import 'shelf_element.dart';

class BooksOnShelf extends ConsumerStatefulWidget {
  final Shelf shelf;

  const BooksOnShelf({super.key, required this.shelf});

  @override
  ConsumerState<BooksOnShelf> createState() => _BooksOnShelf();
}

class _BooksOnShelf extends ConsumerState<BooksOnShelf> {
  Shelf get shelf => widget.shelf;
  Set<int> visibleBooks = {};
  GlobalKey? firstUnreadBook;

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
                    return const Text('');
                  }

                  String title = book.title.split(':').first;
                  GlobalKey key = GlobalKey(debugLabel: '${shelf.collection.getNameNormalised()}-$index');
                  if (!book.readStatus) {
                    firstUnreadBook ??= key;
                  }
                  return VisibilityDetector(
                    key: key,
                    onVisibilityChanged: (visibility) => _updateVisibility(index + 1, visibility.visibleFraction > 0.5),
                    child: InkWell(
                      onTap: () => _openBook(bookShelf[index]),
                      child: ShelfElement(bookUuid: bookShelf[index], title: title, shelfTitleGroup: shelfTitleGroup),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFirstUnreadBook());
  }

  void _openBook(String bookUuid) {
    ref.read(navigatorStackProvider.notifier).push(context, "back_cover", MaterialPageRoute(builder: (context) => BackCover(bookUuid: bookUuid), settings: RouteSettings(name: "/home")));
  }

  void _scrollToFirstUnreadBook() {
    final context = firstUnreadBook?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: Duration(milliseconds: 500), curve: Curves.easeInOut,);
    }
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
