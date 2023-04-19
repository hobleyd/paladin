import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/collection.dart';
import '../notifiers/library_db.dart';
import 'booklist.dart';
import 'collectionlist.dart';

class MenuButtons extends StatefulWidget {
  const MenuButtons({Key? key}) : super(key: key);

  @override
  _MenuButtons createState() => _MenuButtons();
}

class _MenuButtons extends State<MenuButtons> {
  late LibraryDB _library;
  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryDB>(builder: (ctx, model, child) {
      _library = model;

      return Ink(
          child: IntrinsicHeight(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _getButton(
              context,
              'Books\n(${_library.tableCount['books']})',
              Collection(type: CollectionType.BOOK, query: 'select * from books order by added desc;'),
            ),
            const VerticalDivider(color: Colors.black, thickness: 1),
            _getButton(
                context,
                'Authors\n(${_library.tableCount['authors']})',
                Collection(
                    type: CollectionType.AUTHOR,
                    query:
                        'select authors.id, authors.name, count(book_authors.bookId) as count from authors left join book_authors on authors.id = book_authors.authorId group by authors.id order by authors.name')),
            const VerticalDivider(color: Colors.black, thickness: 1),
            _getButton(
                context,
                'Series\n(${_library.tableCount['series']})',
                Collection(
                    type: CollectionType.SERIES,
                    query:
                        'select series.id, series.series, count(books.uuid) as count from series left join books on books.series = series.id group by series.id order by series.series;')),
            const VerticalDivider(color: Colors.black, thickness: 1),
            _getButton(
                context,
                'Tags\n(${_library.tableCount['tags']})',
                Collection(
                    type: CollectionType.TAG,
                    query:
                        'select tags.id, tags.tag, count(book_tags.tagId) as count from tags left join book_tags on tags.id = book_tags.tagId group by tags.id order by tags.tag')),
            const VerticalDivider(color: Colors.black, thickness: 1),
            _getButton(context, 'Settings\n(${_library.tableCount['settings']})', Collection(type: CollectionType.SETTINGS)),
          ])));
    });
  }

  Widget _getButton(BuildContext context, String label, Collection collection) {
    return Expanded(
        child: TextButton(
      onPressed: () => _navigateToCollection(context, collection),
      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white), foregroundColor: MaterialStatePropertyAll(Colors.black)),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ));
  }

  Future _navigateToCollection(BuildContext context, Collection collection) async {
    collection.type == CollectionType.BOOK
        ? Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: collection)))
        : Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionList(collection: collection)));

    return null;
  }
}
