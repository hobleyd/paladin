import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/shelf.dart';
import '../../repositories/shelf_repository.dart';
import '../../repositories/shelves_repository.dart';
import '../home/fatal_error.dart';

class ShelfSize extends ConsumerWidget {
  static const List<int> shelfSizes = [10, 15, 20, 30];
  final int shelfId;

  const ShelfSize({super.key, required this.shelfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelfAsync = ref.watch(shelfRepositoryProvider(shelfId));

    return shelfAsync.when(error: (error, stackTrace) {
      return FatalError(error: "$error", trace: stackTrace);
    }, loading: () {
    return const Center(child: CircularProgressIndicator());
    }, data: (Shelf shelf) {
      return shelf.needsSize
          ? InputDecorator(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                labelStyle: Theme.of(context).textTheme.labelLarge,
                labelText: 'Size',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: shelfSizes.contains(shelf.size) ? shelf.size : shelfSizes.last,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  isExpanded: true,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                  onChanged: (int? size) {
                    ref.read(shelfRepositoryProvider(shelf.shelfId).notifier).updateShelfSize(size!);
                  },
                  items: shelfSizes.map((item) {
                    return DropdownMenuItem(value: item, child: Text('$item'));
                  }).toList(),
                ),
              ),
            )
          : const Text('');
    });
  }
}