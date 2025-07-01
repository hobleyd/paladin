import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intersperse/intersperse.dart';
import 'package:paladin/repositories/books_repository.dart';
import 'package:paladin/repositories/shelves_repository.dart';
import 'package:paladin/screens/calibresync.dart';

import '../models/book.dart';
import '../models/collection.dart';
import '../models/shelf.dart';
import '../widgets/books/book_tile.dart';
import '../widgets/books/bookshelf.dart';
import '../widgets/menu/menu_buttons.dart';
import '../widgets/menu/paladin_menu.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelves = ref.watch(shelvesRepositoryProvider);
    var bookCount = ref.watch(booksRepositoryProvider);

    return shelves.when(error: (error, stackTrace) {
      return Scaffold(
        appBar: null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: _getInitialInstructions(context, bookCount.value),
          ),
        ),
      );
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Shelf> shelves) {
      Book? book;
      for (var shelf in shelves) {
        if (shelf.name == Collection.collectionTypes[CollectionType.RANDOM]) {

        }
      }
      return Scaffold(
        appBar: null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Column(
              crossAxisAlignment: book != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                book != null
                    ? Expanded(
                        child: BookTile(
                        book: book,
                        showMenu: true,
                      ))
                    : _getInitialInstructions(context, bookCount.value),
                const SizedBox(height: 3),
                const Divider(thickness: 1, height: 3, color: Colors.black),
                const MenuButtons(),
                const Divider(thickness: 1, height: 3, color: Colors.black),
                ..._getShelves(shelves),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _getInitialInstructions(BuildContext context, int? count) {
    return Expanded(
      child: Stack(
        children: [
          Center(
              child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
                  child: count == null || count == 0
                      ? TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CalibreSync())),
                          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white), foregroundColor: WidgetStatePropertyAll(Colors.black)),
                          child: Text(
                            'Synchronise Library',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        )
                      : Text('Congratulations on your new eReader. Pick a book. Enjoy!',
                          textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
              ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PaladinMenu(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getShelves(List<Shelf> shelves) {
    return intersperse(
        const Divider(thickness: 1, height: 3, color: Colors.black),
        shelves.map(
          (shelf) => Expanded(
            child: BookShelf(
              shelf: shelf,
            ),
          ),
        )).toList();
  }
}