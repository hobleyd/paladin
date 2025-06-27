import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/collection.dart';
import '../database/library_db.dart';
import '../widgets/books/book_tile.dart';

class BookList extends StatefulWidget {
  final Collection collection;
  const BookList({Key? key, required this.collection}) : super(key: key);

  @override
  _BookList createState() => _BookList();
}

class _BookList extends State<BookList> {
  late LibraryDB _library;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryDB>(builder: (context, model, child) {
      _library = model;
      _library.getCollection(widget.collection);

      return Scaffold(
          appBar: AppBar(
              title: Text('Books', style: Theme.of(context).textTheme.titleLarge),
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
                IconButton(icon: const Icon(Icons.search), onPressed: _search),
                IconButton(icon: const Icon(Icons.menu), onPressed: null),
              ]),
          body:
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6, right: 10),
              child: ListView.builder(
                    itemCount: _library.collection[widget.collection.getType()]?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _library.collection[widget.collection.getType()] != null
                          ? Column(children: [
                              SizedBox(height: MediaQuery.of(context).size.height / 6, child: BookTile(book: _library.collection[widget.collection.getType()]![index] as Book, showMenu: false,)),
                              const Divider(color: Colors.black, thickness: 1),
                          ])
                          : const Text(
                              "The library elves simply can't find any books in this collection!",
                              textAlign: TextAlign.center,
                            );
                    },
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true
                  ),
                ));
    });
  }

  void _search() {
    String searchTerm = '%${searchController.text.replaceAll(' ', '%')}%';
    widget.collection.queryArgs = [searchTerm];
    widget.collection.key = searchTerm;
    _library.getCollection(widget.collection);
  }
}