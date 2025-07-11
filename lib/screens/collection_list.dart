import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/collection.dart';
import '../repositories/shelf_repository.dart';
import '../widgets/books/collection_tile_list.dart';

class CollectionList extends ConsumerWidget {
  final TextEditingController searchController = TextEditingController();
  final Collection collection;

  CollectionList({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      return Scaffold(
          appBar: AppBar(
              title: Text(collection.getType(), style: Theme.of(context).textTheme.titleLarge),
              actions: <Widget>[
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'search...',
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.search), onPressed: () => _search(ref)),
                IconButton(icon: const Icon(Icons.menu), onPressed: null),
              ]),
          body: Padding(
              padding: const EdgeInsets.only(left: 10, top: 6, right: 10, bottom: 6),
              child: CollectionTileList(collection: collection),
          ),
      );
    }

  void _search(WidgetRef ref) {
    String searchTerm = '%${searchController.text.replaceAll(' ', '%')}%';
    collection.queryArgs = [searchTerm];
    ref.read(shelfRepositoryProvider(collection).notifier).updateCollection(collection);
  }
}
