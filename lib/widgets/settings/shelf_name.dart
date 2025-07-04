import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:paladin/database/library_db.dart';

import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../repositories/shelves_repository.dart';

class ShelfName extends ConsumerWidget {
  final TextEditingController typeAheadController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final Shelf shelf;

  ShelfName({super.key, required this.shelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    typeAheadController.text = shelf.name;

    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
        labelText: 'Name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      child: TypeAheadField<String>(
        builder: (context, controller, focusNode) {
          return TextField(
            autofocus: false,
            controller: typeAheadController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
            enabled: !(shelf.type == CollectionType.CURRENT || shelf.type == CollectionType.RANDOM),
            focusNode: focusNode,
          );
        },
        itemBuilder: (context, String shelfName) {
          return Padding(padding: const EdgeInsets.only(top: 3, bottom: 3, left: 6), child: Text(shelfName));
        },
        onSelected: (String shelfName) {
          shelf.name = shelfName;
          typeAheadController.text = shelf.name;
          ref.read(shelvesRepositoryProvider.notifier).updateShelf(shelf);
        },
        suggestionsCallback: (String pattern) async {
          if (pattern.length <= 3) {
            return [];
          }
          return getShelfName(ref, Shelf.shelfTable[shelf.type]!, Shelf.shelfTableColumn[shelf.type]!, pattern, shelf.size);
        },
      ),
    );
  }

  Future<List<String>> getShelfName(WidgetRef ref, String table, String column, String query, int size) async {
    List<Map<String, dynamic>> results = await ref.read(libraryDBProvider.notifier).query(table: table, columns: [column], where: '$column like ?', whereArgs: ['%${query.replaceAll(' ', '%')}%'], limit: size);
    return results.map((element) => element[column] as String).toList();
  }
}