import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../models/collection.dart';
import '../repositories/shelf_repository.dart';
import '../widgets/books/book_tile.dart';

class BookList extends ConsumerWidget {
  final TextEditingController searchController = TextEditingController();
  final Collection collection;

  BookList({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  var bookListAsync = ref.watch(shelfRepositoryProvider(collection));
      return bookListAsync.when(error: (error, stackTrace) {
      return const Text('Wow! A diskless computer!');
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (List<Book> bookList) {
      return Scaffold(
        appBar: AppBar(title: Text('Books', style: Theme.of(context).textTheme.titleLarge), actions: <Widget>[
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
          padding: const EdgeInsets.only(top: 6, bottom: 6, right: 10),
          child: ListView.builder(
              itemCount: bookList.length ?? 0,
              itemBuilder: (context, index) {
                return bookList.isNotEmpty
                    ? Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 6,
                              child: BookTile(
                                book: bookList[index],
                                showMenu: false,
                              )),
                          const Divider(color: Colors.black, thickness: 1),
                        ],
                      )
                    : const Text(
                        "The library elves simply can't find any books in this collection!",
                        textAlign: TextAlign.center,
                      );
              },
              scrollDirection: Axis.vertical,
              shrinkWrap: true),
        ),
      );
    });
  }

  void _search(WidgetRef ref) {
    String searchTerm = '%${searchController.text.replaceAll(' ', '%')}%';
    collection.queryArgs = [searchTerm];
    ref.read(shelfRepositoryProvider(collection).notifier).updateCollection(collection);
  }
}