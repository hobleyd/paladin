import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:paladin/database/library_db.dart';
import 'package:paladin/repositories/shelf_repository.dart';

import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../home/fatal_error.dart';

class ShelfName extends ConsumerWidget {
  final int shelfId;

  const ShelfName({super.key, required this.shelfId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var shelfAsync = ref.watch(shelfRepositoryProvider(shelfId));

    return shelfAsync.when(error: (error, stackTrace) {
      return FatalError(error: "$error", trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (Shelf shelf) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            labelStyle: Theme.of(context).textTheme.labelLarge,
            labelText: 'Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          ),
          child: TypeAheadField<String>(
            builder: (context, controller, focusNode) {
              controller.text = shelf.name;
              focusNode.unfocus();

              return TextField(
                autofocus: false,
                controller: controller,
                decoration: InputDecoration(border: OutlineInputBorder()),
                enabled: !(shelf.type == CollectionType.CURRENT || shelf.type == CollectionType.RANDOM),
                focusNode: focusNode,
                onTap: () => controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.value.text.length),
              );
            },
            itemBuilder: (context, String shelfName) {
              return Padding(padding: const EdgeInsets.only(top: 3, bottom: 3, left: 6), child: Text(shelfName));
            },
            onSelected: (String shelfName) {
              ref.read(shelfRepositoryProvider(shelf.shelfId).notifier).updateShelfName(shelfName);
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
    );
  }

  Future<List<String>> getShelfName(WidgetRef ref, String table, String column, String query, int size) async {
    List<Map<String, dynamic>> results = await ref.read(libraryDBProvider.notifier).query(table: table, columns: [column], where: '$column like ?', whereArgs: ['%${query.replaceAll(' ', '%')}%'], limit: size);
    return results.map((element) => element[column] as String).toList();
  }
}