import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';
import '../../models/shelf.dart';
import '../../repositories/shelf_repository.dart';
import '../../screens/calibresync.dart';
import '../books/book_tile.dart';
import '../menu/paladin_menu.dart';
import 'fatal_error.dart';

class CurrentlyReading extends ConsumerWidget {
  final Shelf currentlyReading;

  const CurrentlyReading({super.key, required this.currentlyReading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelfAsync = ref.watch(shelfRepositoryProvider(currentlyReading.collection));

    return shelfAsync.when(error: (error, stackTrace) {
      debugPrint('HomeScreen.build: $stackTrace');
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Book> books) {
      return books.isNotEmpty
          ? Expanded(
              child: BookTile(
                book: books[0],
                showMenu: true,
              ),
            )
          : _getInitialInstructions(context, books.length);
    });
  }

  Widget _getInitialInstructions(BuildContext context, int count) {
    return Expanded(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
              child: count == 0
                  ? TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CalibreSync())),
                      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white), foregroundColor: WidgetStatePropertyAll(Colors.black)),
                      child: Text(
                        'Synchronise Library',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  : Text('Congratulations on your new eReader. Pick a book. Enjoy!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
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
}