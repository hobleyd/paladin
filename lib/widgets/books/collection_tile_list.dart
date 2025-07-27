import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/collection_repository.dart';
import 'package:paladin/widgets/home/fatal_error.dart';

import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../screens/book_list.dart';

class CollectionTileList extends ConsumerWidget {
  final Collection collection;

  const CollectionTileList({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var collectionListAsync = ref.watch(collectionRepositoryProvider(collection));
    return collectionListAsync.when(error: (error, trace) {
      return FatalError(error: "It's a crime; your book collection is empty!", trace: trace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Collection> collectionList) {
      return ListView.builder(
              itemCount: collectionList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => _navigateToCollection(context, collectionList[index]),
                  child: Container(
                    color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                    padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                    child: Text(collectionList[index].toString(), style: Theme.of(context).textTheme.labelSmall),
                  ),
                );
              },
              scrollDirection: Axis.vertical,
              shrinkWrap: true);
    });
  }

  Future _navigateToCollection(BuildContext context, Collection collection) async {
    final Collection collectionQuery = Collection(
        type: CollectionType.BOOK,
        query: Shelf.shelfQuery[collection.type]!,
        queryArgs: [...?collection.queryArgs, if (Shelf.shelfNeedsSize(collection.type)) collection.count],
        count: collection.count
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: collectionQuery)));

    return null;
  }
}