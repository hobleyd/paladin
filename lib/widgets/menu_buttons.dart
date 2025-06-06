import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:paladin/widgets/settings.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../models/collection.dart';
import '../models/series.dart';
import '../models/tag.dart';
import '../providers/library_db.dart';
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
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _getButtons())));
    });
  }

  Widget _getButton(String label, Collection collection) {
    return Expanded(child: TextButton(
      onPressed: () => _navigateToCollection(context, collection),
      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white), foregroundColor: MaterialStatePropertyAll(Colors.black)),
      child: Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall,),
    ));
  }

  List<Widget> _getButtons() {
    return intersperse(const VerticalDivider(color: Colors.black, thickness: 1), [
      _getButton('Books\n(${_library.tableCount['books']})', Collection(type: CollectionType.BOOK, query: Book.booksQuery, queryArgs: ['%']),),
      _getButton('Authors\n(${_library.tableCount['authors']})', Collection(type: CollectionType.AUTHOR, query: Author.authorsQuery, queryArgs: ['%'])),
      _getButton('Series\n(${_library.tableCount['series']})', Collection(type: CollectionType.SERIES, query: Series.seriesQuery, queryArgs: ['%'])),
      _getButton('Tags\n(${_library.tableCount['tags']})', Collection(type: CollectionType.TAG, query: Tag.tagsQuery, queryArgs: ['%'])),
      _getButton('Settings\n(${_library.tableCount['settings']})', Collection(type: CollectionType.SETTINGS)),
    ]).toList();
  }

  Future _navigateToCollection(BuildContext context, Collection collection) async {
    switch (collection.type) {
      case CollectionType.BOOK:
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: collection)))
            .then((value) => _library.updateFields(null));
        return;
      case CollectionType.SETTINGS:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings())).then((value) => _library.updateFields(null));
        return;
      default:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionList(collection: collection)))
            .then((value) => _library.updateFields(null));
        return;
    }
  }
}
