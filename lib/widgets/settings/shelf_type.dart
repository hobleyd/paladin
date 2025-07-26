import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../repositories/shelves_repository.dart';

class ShelfType extends ConsumerWidget {
  final Shelf shelf;
  const ShelfType({super.key, required this.shelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 150,
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          labelStyle: Theme.of(context).textTheme.labelLarge,
          labelText: 'Shelf Type',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            value: shelf.type,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.black, fontSize: 10),
            onChanged: (CollectionType? value) {
              shelf.collection.type = value!;
              shelf.name = (value == CollectionType.CURRENT || value == CollectionType.RANDOM) ? Collection.collectionTypes[value]! : "";
              ref.read(shelvesRepositoryProvider.notifier).updateShelf(shelf);
            },
            items: Collection.collectionTypes.entries.map((item) {
              return DropdownMenuItem(value: item.key, child: Text(item.value));
            }).toList(),
          ),
        ),
      ),
    );
  }
}