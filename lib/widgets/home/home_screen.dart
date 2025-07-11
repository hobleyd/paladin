import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intersperse/intersperse.dart';
import 'package:paladin/repositories/books_repository.dart';
import 'package:paladin/repositories/shelves_repository.dart';
import 'package:paladin/widgets/home/currently_reading.dart';
import 'package:paladin/widgets/home/fatal_error.dart';

import '../../models/shelf.dart';
import '../books/bookshelf.dart';
import '../menu/menu_buttons.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelves = ref.watch(shelvesRepositoryProvider);

    return shelves.when(error: (error, stackTrace) {
      debugPrint('HomeScreen.build: $stackTrace');
      return FatalError(error:error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Shelf> shelves) {
      debugPrint('shelves: ${shelves[0].collection}');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrentlyReading(currentlyReading: shelves[0]),
          const SizedBox(height: 3),
          const Divider(thickness: 1, height: 3, color: Colors.black),
          const MenuButtons(),
          const Divider(thickness: 1, height: 3, color: Colors.black),
          ..._getShelves(shelves),
        ],
      );
    });
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