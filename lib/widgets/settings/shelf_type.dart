import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../repositories/shelf_repository.dart';
import '../home/fatal_error.dart';

class ShelfType extends ConsumerWidget {
  final int shelfId;
  const ShelfType({super.key, required this.shelfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelfAsync = ref.watch(shelfRepositoryProvider(shelfId));

    return shelfAsync.when(error: (error, stackTrace) {
      return FatalError(error: "$error", trace: stackTrace);
    }, loading: () {
    return const Center(child: CircularProgressIndicator());
    }, data: (Shelf shelf) {
      return SizedBox(
        width: 170,
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
                ref.read(shelfRepositoryProvider(shelf.shelfId).notifier).updateShelfType(value!);
              },
              items: Shelf.shelfQuery.keys.map((type) {
                return DropdownMenuItem(value: type, child: Text(Collection.collectionType(type)));
              }).toList(),
            ),
          ),
        ),
      );
    });
  }
}