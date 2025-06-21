import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/cached_cover.dart';

import '../models/book.dart';
import '../models/collection.dart';
import '../database/library_db.dart';

class BookShelf extends ConsumerStatefulWidget {
  final Collection collection;

  const BookShelf({super.key, required this.collection});

  @override
  ConsumerState<BookShelf> createState() => _BookShelf();
}

class _BookShelf extends ConsumerState<BookShelf> {

  get collection => widget.collection;

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
                child: Text(
                  '${widget.items.getType()} (${_library.collection[collection.getType()]?.length})',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
            ),
            Expanded(child: ListView.builder(
              itemCount: _library.collection[widget.items.getType()]?.length,
              itemBuilder: (context, index) {
                Book book;
                String title = book.title.split(':').first;

                return InkWell(
                    onTap: () => _openBook(context, book),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          Expanded(child: ref.watch(cachedCoverProvider(book))),
                          const SizedBox(height: 3),
                          SizedBox(
                            width: 80,
                            child: AutoSizeText(title, maxLines: 2, style: Theme
                                .of(context)
                                .textTheme
                                .bodySmall, textAlign: TextAlign.center,),
                          ),
                        ],
                        ),
                    ),
                );
              },
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
            )),
      ],
      );
  }

  Future _openBook(BuildContext context, Book book) async {
    book.readBook(context);
  }
}