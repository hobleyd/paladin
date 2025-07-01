import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/library_db.dart';
import '../models/shelf.dart';
import '../widgets/settings/shelfsetting.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  _Settings createState() => _Settings();
}

class _Settings extends ConsumerState<Settings> {
  late LibraryDB _library;

  @override
  Widget build(BuildContext context) {
    List<Shelf> shelves = shelvesRepositoryProvider().value;
    final List<Widget> settings = shelves.map((shelf) {
      return ShelfSetting(shelfId: shelf.shelfId!);
    }).toList();

    final List<Widget> add = [
      Center(
        child: Row(
          children: [
            Padding(padding: const EdgeInsets.only(top: 10), child: IconButton(icon: const Icon(Icons.remove), onPressed: () => _removeShelf())),
            const SizedBox(width: 10),
            Padding(padding: const EdgeInsets.only(top: 10), child: IconButton(icon: const Icon(Icons.add), onPressed: () => _addShelf())),
          ],
        ),
      ),
    ];

    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: Column(children: [...settings, ...add]));
  }

  void _addShelf() {
    _library.addShelf();
  }

  void _removeShelf() {

  }
}