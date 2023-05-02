import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:paladin/models/collection.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/shelf.dart';
import '../notifiers/calibre_ws.dart';

import '../notifiers/library_db.dart';
import 'bookshelf.dart';
import 'booktile.dart';
import 'calibresync.dart';
import 'menu_buttons.dart';

class Paladin extends StatelessWidget {
  late LibraryDB _library;
  Paladin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryDB>(builder: (context, model, child) {
      _library = model;

      Book? book;
      if (model.collection.containsKey('Currently Reading') && model.collection['Currently Reading']!.isNotEmpty) {
        book = model.collection['Currently Reading']!.first as Book;
      }

      return Scaffold(
          appBar: null,
          body: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Column(crossAxisAlignment: book != null ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
                book != null
                    ? Expanded(child: BookTile(book: book, showMenu: true,))
                    : const Expanded(
                        child: Center(
                            child: Text('Congratulations on your new eReader. Pick a book. Enjoy!',
                                textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                const SizedBox(height: 3),
                const Divider(thickness: 1, height: 3, color: Colors.black),
                const MenuButtons(),
                const Divider(thickness: 1, height: 3, color: Colors.black),
                ..._getShelves(),
              ])));
    });
  }

  List<Widget> _getShelves() {
    if (_library.shelves.isEmpty) {
      return [Expanded(child: BookShelf(items: Collection(type: CollectionType.CURRENT)))];
    }
    
    return intersperse(
        const Divider(thickness: 1, height: 3, color: Colors.black),
        _library.shelves.map((e) => Expanded(child: BookShelf(
            items: Collection(
                type: e.type == CollectionType.CURRENT ? CollectionType.CURRENT : e.type == CollectionType.RANDOM ? CollectionType.RANDOM : CollectionType.BOOK,
                key: e.name,
                query: Shelf.shelfQuery[e.type],
                queryArgs: [e.name]))))).toList();
  }

  void _showSyncDialog(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
            create: (context) => CalibreWS(context),
            builder: (context, child) => const CalibreSync()))).then((value) => _library.updateFields(null));
  }
}
