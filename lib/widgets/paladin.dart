import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intersperse/intersperse.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:paladin/models/collection.dart';

import '../models/book.dart';
import '../models/shelf.dart';
import '../repositories/calibre_ws.dart';
import '../providers/library_db.dart';

import 'bookshelf.dart';
import 'booktile.dart';
import 'calibresync.dart';
import 'menu_buttons.dart';
import 'paladinmenu.dart';

class Paladin extends ConsumerWidget {
  late LibraryDB _library;
  Paladin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LibraryDB = ref.watch(paladinDatabase());

    return Consumer<LibraryDB>(builder: (context, model, child) {
      _library = model;

      Book? book;
      if (model.collection.containsKey('Currently Reading') && model.collection['Currently Reading']!.isNotEmpty) {
        book = model.collection['Currently Reading']!.first as Book;
      }

      return Scaffold(
          appBar: null,
          body: SafeArea(child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Column(crossAxisAlignment: book != null ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
                book != null
                    ? Expanded(child: BookTile(book: book, showMenu: true,))
                    : _getInitialInstructions(context),
                const SizedBox(height: 3),
                const Divider(thickness: 1, height: 3, color: Colors.black),
                const MenuButtons(),
                const Divider(thickness: 1, height: 3, color: Colors.black),
                ..._getShelves(),
              ]))));
    });
  }

  Widget _getInitialInstructions(BuildContext context) {
    return Expanded(child: Stack(children: [
      Center(child: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
          child: _library.tableCount['books'] == 0
              ? TextButton(
                  onPressed: () => _showSyncDialog(context),
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white), foregroundColor: MaterialStatePropertyAll(Colors.black)),
                  child: Text(
                    'Synchronise Library',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                )
              : Text('Congratulations on your new eReader. Pick a book. Enjoy!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall))),
      Align(
          alignment: Alignment.topRight,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            PaladinMenu(),
          ])),
    ]));
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
            builder: (context, child) => const CalibreSync()))).then((value) {
              if (Platform.isAndroid || Platform.isIOS) {
                KeepScreenOn.turnOff();
              }
              _library.updateFields(null);
    });
  }
}
