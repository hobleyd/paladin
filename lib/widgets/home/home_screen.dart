import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intersperse/intersperse.dart';
import 'package:paladin/repositories/shelves_repository.dart';
import 'package:paladin/widgets/home/fatal_error.dart';

import '../shelf/bookshelf.dart';
import '../menu/menu_buttons.dart';
import 'currently_reading.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelves = ref.watch(shelvesRepositoryProvider);

    return shelves.when(error: (error, stackTrace) {
      return FatalError(error:error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<int> shelfIds) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrentlyReading(shelfId: shelfIds.first),
          const SizedBox(height: 3),
          const Divider(thickness: 1, height: 3, color: Colors.black),
          const MenuButtons(),
          const Divider(thickness: 1, height: 3, color: Colors.black),
          ..._getShelves(shelfIds),
        ],
      );
    });
  }

  List<Widget> _getShelves(List<int> shelfIds) {
    return intersperse(
        const Divider(thickness: 1, height: 3, color: Colors.black),
        shelfIds.map((shelfId) => Expanded(child: BookShelf(shelfId: shelfId)))
    ).toList();
  }
}