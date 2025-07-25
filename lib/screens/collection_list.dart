import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/collection_repository.dart';

import '../models/collection.dart';
import '../widgets/books/collection_tile_list.dart';

class CollectionList extends ConsumerStatefulWidget {
  final Collection collection;

  CollectionList({super.key, required this.collection});

  @override
  ConsumerState<CollectionList> createState() => _CollectionList();
}

class _CollectionList extends ConsumerState<CollectionList> {
  final TextEditingController searchController = TextEditingController();

  Collection get collection => widget.collection;

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
              title: Text(collection.getLabel(), style: Theme.of(context).textTheme.titleLarge),
              actions: <Widget>[
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'search...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.search), onPressed: () => _search()),
                IconButton(icon: const Icon(Icons.menu), onPressed: null),
              ]),
          body: Padding(
              padding: const EdgeInsets.only(left: 10, top: 6, right: 10, bottom: 6),
              child: CollectionTileList(collection: collection),
          ),
      );
    }

  void _search() {
    setState(() {
      String searchTerm = '%${searchController.text.replaceAll(' ', '%')}%';
      collection.queryArgs = [searchTerm];
      ref.read(collectionRepositoryProvider(collection).notifier).updateCollection(collection);
    });
  }
}
