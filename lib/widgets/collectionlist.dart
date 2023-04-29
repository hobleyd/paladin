import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/collection.dart';
import '../models/series.dart';
import '../models/tag.dart';
import '../notifiers/library_db.dart';
import 'booklist.dart';
import 'booktile.dart';

class CollectionList extends StatefulWidget {
  final Collection collection;
  const CollectionList({Key? key, required this.collection}) : super(key: key);

  @override
  _CollectionList createState() => _CollectionList();
}

class _CollectionList extends State<CollectionList> {
  late LibraryDB _library;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Consumer<LibraryDB>(builder: (context, model, child) {
      _library = model;
      _library.getCollection(widget.collection);

      return Scaffold(
          appBar: AppBar(
              title: Text(widget.collection.getType(), style: Theme.of(context).textTheme.titleLarge),
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
          body: Padding(
              padding: const EdgeInsets.only(left: 10, top: 6, right: 10, bottom: 6),
              child: Scrollbar(
                  controller: scrollController,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: ListView.builder(
                        itemCount: _library.collection[widget.collection.getType()]?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Container(
                              color: index % 2 == 0 ? Colors.grey : Colors.white,
                              padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () => _navigateToCollection(context, _getCollection(index)),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            (index % 2 == 0) ? const MaterialStatePropertyAll(Colors.grey) : const MaterialStatePropertyAll(Colors.white),
                                        foregroundColor: const MaterialStatePropertyAll(Colors.black)),
                                    child: _getLabel(index),
                                  )));
                        },
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true),
                  ))));
    });
  }

  String _getAuthors(List<Collection>? coll, int index) {
    String result = "";
    if (coll != null) {
      Author author = coll[index] as Author;
      result = '${author.name} [${author.count}]';
    }
    return result;
  }

  Collection? _getCollection(int index) {
    switch (widget.collection.type) {
      case CollectionType.AUTHOR:
        final Author author = _library.collection[widget.collection.getType()]![index] as Author;
        return author.getBookCollection();
      case CollectionType.SERIES:
        final Series series = _library.collection[widget.collection.getType()]![index] as Series;
        return series.getBookCollection();
      case CollectionType.TAG:
        final Tag tag = _library.collection[widget.collection.getType()]![index] as Tag;
        return tag.getBookCollection();
      default:
        return null;
    }
  }

  Widget _getLabel(int index) {
    if (_library.collection[widget.collection.getType()] == null) {
      return const Text(
        "The library elves simply can't find any books in this collection!",
        textAlign: TextAlign.center,
      );
    }

    switch (widget.collection.type) {
      case CollectionType.AUTHOR:
        return Text(_getAuthors(_library.collection[widget.collection.getType()], index));
      case CollectionType.SERIES:
        return Text(_getSeries(_library.collection[widget.collection.getType()], index));
      case CollectionType.TAG:
        return Text(_getTags(_library.collection[widget.collection.getType()], index));
      default:
        return const Text(
          "The library elves simply can't find any books in this collection!",
          textAlign: TextAlign.center,
        );
    }
  }

  String _getSeries(List<Collection>? coll, int index) {
    String result = "";
    if (coll != null) {
      Series series = coll[index] as Series;
      result = '${series.series} [${series.count}]';
    }
    return result;
  }

  String _getTags(List<Collection>? coll, int index) {
    String result = "";
    if (coll != null) {
      Tag tag = coll[index] as Tag;
      result = '${tag.tag} [${tag.count}]';
    }
    return result;
  }

  Future _navigateToCollection(BuildContext context, Collection? collection) async {
    if (collection != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: collection)));
    }

    return null;
  }

  void _search() {
    String searchTerm = '%${searchController.text.replaceAll(' ', '%')}%';
    widget.collection.queryArgs = [searchTerm];
    widget.collection.key = searchTerm;
    _library.getCollection(widget.collection);
  }
}
