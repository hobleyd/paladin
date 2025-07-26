import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shelf.dart';
import '../repositories/shelves_repository.dart';
import '../widgets/settings/shelf_setting.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _Settings();
}

class _Settings extends ConsumerState<Settings> {
  List<Shelf> shelves = [];

  @override
  Widget build(BuildContext context) {
    var shelves = ref.watch(shelvesRepositoryProvider);

    return shelves.when(error: (error, stackTrace) {
      return const Center(child: Text("Your shelves have gone missing; it's a catastrophe! Seriously though, maybe add a Shelf below..."));
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Shelf> shelves) {
      this.shelves = shelves;

      final List<Widget> settings = shelves.map((shelf) {
        return ShelfSetting(shelf: shelf);
      }).toList();

      final List<Widget> add = [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.only(top: 10), child: IconButton(icon: const Icon(Icons.remove), onPressed: () => _removeShelf())),
            const SizedBox(width: 10),
            Padding(padding: const EdgeInsets.only(top: 10), child: IconButton(icon: const Icon(Icons.add), onPressed: () => _addShelf())),
          ],
        ),
      ];

      return Scaffold(appBar: AppBar(title: const Text('Settings')), body: Column(children: [...settings, ...add]));
    });
  }

  void _addShelf() {
    ref.read(shelvesRepositoryProvider.notifier).addShelf();
  }

  void _removeShelf() {
    if (shelves.isNotEmpty && shelves.length > 1) {
      ref.read(shelvesRepositoryProvider.notifier).removeShelf(shelves.last);
    }

    // TODO: status message if not successful
  }
}