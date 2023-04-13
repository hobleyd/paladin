import 'package:flutter/material.dart';
import 'package:paladin/models/collection.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/series.dart';
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
          appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/sharpblue.png',),),
              title: Text("Paladin", style: Theme.of(context).textTheme.titleLarge),
              actions: <Widget>[
                IconButton(icon: const Icon(Icons.sync), tooltip: 'Sync', onPressed: () => _showSyncDialog(context)),
                IconButton(icon: const Icon(Icons.open_with), tooltip: 'Read Book', onPressed: () {}),
              ]),
          body: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Column(crossAxisAlignment: book != null ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
                book != null
                    ? Expanded(child: BookTile(book: book))
                    : const Expanded(
                        child: Center(
                            child: Text('Congratulations on your new eReader. Pick a book. Enjoy!',
                                textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                const SizedBox(height: 3),
                const Divider(thickness: 1, height: 3, color: Colors.black),
                const MenuButtons(),
                ..._getShelves(),
              ])));
    });
  }

  List<Widget> _getShelves() {
    return [
      const Divider(thickness: 1, height: 3, color: Colors.black),
      Expanded(child: BookShelf(items: Collection(type: CollectionType.CURRENT))),
      const Divider(thickness: 1, height: 3, color: Colors.black),
      Expanded(child: BookShelf(items: Collection(type: CollectionType.BOOK, query: 'select * from books where series = (select id from series where series = ?);', queryArgs: ['Jackpot'], key: 'Jackpot'))),
      const Divider(thickness: 1, height: 3, color: Colors.black),
      Expanded(child: BookShelf(items: Collection(type: CollectionType.BOOK, query: 'select * from books where uuid in (select bookId from book_tags where tagId = ?)', queryArgs: [3], key: 'Magic'))),
      const Divider(thickness: 1, height: 3, color: Colors.black),
      Expanded(child: BookShelf(items: Collection(type: CollectionType.RANDOM))),
    ];
  }

  void _showSyncDialog(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
            create: (context) => CalibreWS(),
            builder: (context, child) => const CalibreSync()))).then((value) => _library.updateFields(null));
  }
}
