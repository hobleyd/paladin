import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifiers/library_db.dart';
import 'shelfsetting.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
  late LibraryDB _library;

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryDB>(builder: (context, model, child) {
      _library = model;

      final List<Widget> settings = _library.shelves.map((shelf) {
        return ShelfSetting(shelfId: shelf.shelfId!);
      }).toList();

      final List<Widget> add = [Center(child: Row(children: [
        Padding(padding: const EdgeInsets.only(top: 10), child: IconButton(icon: const Icon(Icons.remove), onPressed: () => _removeShelf())),
        const SizedBox(width: 10),
        Padding(padding: const EdgeInsets.only(top: 10), child: IconButton(icon: const Icon(Icons.add), onPressed: () => _addShelf())),
      ]))];

      return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Column(children: [...settings, ...add]));
    });
  }

  void _addShelf() {
    _library.addShelf();
  }

  void _removeShelf() {

  }
}