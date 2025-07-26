import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/collection_repository.dart';

import '../../models/collection.dart';
import '../../repositories/shelf_repository.dart';
import '../../screens/book_list.dart';

class CollectionTileList extends ConsumerWidget {
  final ScrollController scrollController = ScrollController();
  final Collection collection;

  CollectionTileList({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var collectionListAsync = ref.watch(collectionRepositoryProvider(collection));
    return collectionListAsync.when(error: (error, stackTrace) {
      // TODO: better error message
      return Text("It's a crime. You have no books!\n$stackTrace");
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Collection> collectionList) {
      return SingleChildScrollView(
          controller: scrollController,
          child: ListView.builder(
              itemCount: collectionList.length,
              itemBuilder: (context, index) {
                return Container(
                  color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                  padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _navigateToCollection(context, collectionList[index]),
                      style: ButtonStyle(
                        backgroundColor: (index % 2 == 0)
                            ? const WidgetStatePropertyAll(Colors.grey)
                            : const WidgetStatePropertyAll(Colors.white),
                        foregroundColor: const WidgetStatePropertyAll(Colors.black),
                      ),
                      child: Text(collectionList[index].toString(), style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ),
                );
              },
              scrollDirection: Axis.vertical,
              shrinkWrap: true),
      );
    });
  }

  Future _navigateToCollection(BuildContext context, Collection? collection) async {
    if (collection != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: collection)));
    }

    return null;
  }
}