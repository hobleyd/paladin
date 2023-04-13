import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/book.dart';
import '../models/collection.dart';
import '../notifiers/library_db.dart';

class BookShelf extends StatefulWidget {
  final Collection items;

  const BookShelf({Key? key, required this.items}) : super(key: key);

  @override
  _BookShelf createState() => _BookShelf();
}

class _BookShelf extends State<BookShelf> {
  late LibraryDB _library;

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryDB>(builder: (context, model, child) {
      _library = model;
      _library.getCollection(widget.items);

      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
                child: Text(
                  '${widget.items.getType()} (${_library.collection[widget.items.getType()]?.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),),
            Expanded(child: ListView.builder(
              itemCount: _library.collection[widget.items.getType()]?.length,
              itemBuilder: (context, index) => _getItemOnShelf(context, index),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
            )),
      ]);
    });
  }

  Widget? _getItemOnShelf(BuildContext context, int index) {
    if (_library.collection[widget.items.getType()] == null) {
      return null;
    }

    Book book = _library.collection[widget.items.getType()]![index] as Book;
    String title = book.title.split(':').first;
    Image cover = book.cachedCover != null && book.cachedCover!.existsSync()
        ? Image.file(book.cachedCover!, fit: BoxFit.cover)
        : Image.asset('assets/generic_book_cover.png', fit: BoxFit.cover);

    // TODO: Fix the const width in the SizedBox
    return InkWell(
        onTap: () => _openBook(context, book),
        child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            color: Colors.yellow,
            child: Column(children: [
              Expanded(child: cover),
              const SizedBox(height: 3),
              SizedBox(
                width: 80,
                child: AutoSizeText(title, maxLines: 2, textAlign: TextAlign.center,),
              ),
            ]))));
  }

  Future _openBook(BuildContext context, Book book) async {
    book.readBook(context);
  }
}