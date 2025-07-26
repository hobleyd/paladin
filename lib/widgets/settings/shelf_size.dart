import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/shelf.dart';
import '../../repositories/shelves_repository.dart';

class ShelfSize extends ConsumerWidget {
  static const List<int> shelfSizes = [10, 15, 20, 30];
  final Shelf shelf;

  const ShelfSize({super.key, required this.shelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          labelStyle: Theme.of(context).textTheme.labelLarge,
          labelText: 'Size',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            value: shelf.size,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            isExpanded: true,
            elevation: 16,
            style: const TextStyle(color: Colors.black, fontSize: 10),
            onChanged: (value) {
              shelf.size = value!;
              ref.read(shelvesRepositoryProvider.notifier).updateShelf(shelf);
            },
            items: shelfSizes.map((item) {
              return DropdownMenuItem(value: item, child: Text('$item'));
            }).toList(),
          ),
        ),
      );
  }
}