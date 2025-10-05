import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/collection.dart';
import '../repositories/collection_list_repository.dart';
import '../widgets/books/book_tile_list.dart';

class BookList extends ConsumerStatefulWidget {
  final Collection collection;

  const BookList({super.key, required this.collection});

  @override
  ConsumerState<BookList> createState() => _BookList();
}

class _BookList extends ConsumerState<BookList> {
  final TextEditingController searchController = TextEditingController();

  Collection get collection => widget.collection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Books', style: Theme.of(context).textTheme.titleLarge), actions: <Widget>[
        SizedBox(
          width: 180,
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'search...',
              hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, ),
            ),
            onSubmitted: (_) => _search(),
            onTap: () => searchController.selection = TextSelection(baseOffset: 0, extentOffset: searchController.value.text.length),
          ),
        ),
        IconButton(icon: const Icon(Icons.search), onPressed: () => _search()),
        IconButton(icon: const Icon(Icons.menu), onPressed: null),
      ]),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 10),
            child: BookTileList(collection: collection),
        ),
      ),
    );
  }

  void _search() {
    setState(() {
      final String searchTerm = '%${searchController.text.replaceAll(' ', '%')}%';
      ref.read(collectionListRepositoryProvider(collection).notifier).updateCollection(collection.copyWith(queryArgs: [searchTerm]));
    });
  }
}