import 'package:dartlin/collections.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/collection.dart';
import '../notifiers/library_db.dart';
import 'booklist.dart';

class BackCover extends StatefulWidget {
  final Book book;
  const BackCover({Key? key, required this.book}) : super(key: key);

  @override
  _BackCover createState() => _BackCover();
}

class _BackCover extends State<BackCover> {
  final ScrollController _scrollController = ScrollController();
  late LibraryDB _library;

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryDB>(builder: (context, model, child) {
      _library = model;

      return Scaffold(
          appBar: AppBar(title: Text(widget.book.title)),
          body: Column(children: [
            IntrinsicHeight(child: Row(children: [
              _getBookCover(),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text(widget.book.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                _getSeries(),
                _getAuthors(),
                _getTags(context),
                RatingBar.builder(
                    direction: Axis.horizontal,
                    glow: false,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.black,),
                    initialRating: widget.book.rating?.toDouble() ?? 0,
                    itemSize: 24,
                    tapOnlyMode: true,
                    onRatingUpdate: (rating) {
                      widget.book.setRating(context, rating.floor());
                    }
                )
              ])),
            ])),
            const Divider(color: Colors.black, thickness: 1),
            widget.book.description != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Scrollbar(
                            controller: _scrollController,
                            child: SingleChildScrollView(controller: _scrollController, child: HtmlWidget(widget.book.description!))))
                : const Center(
                    child: Text(
                        "I know you might expect a back-cover description, but it's a mystery; perhaps you need to read the book to find out what it's about!")),
            const Divider(color: Colors.black, thickness: 1),
            ElevatedButton(onPressed: () => widget.book.readBook(context), child: const Text('Read Book')),
          ]));
    });
  }

  Widget _getAuthors() {
    return RichText(
        text: TextSpan(
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge,
            children: widget.book.authors
                ?.mapIndexed((i, e) =>
                TextSpan(
                    text: '${e.name}${i < widget.book.authors!.length - 1 && i < widget.book.authors!.length ? ', ' : ''}',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _openCollection(e.getBookCollection());
                      }))
                .toList() ??
                []));
  }

  Widget _getBookCover() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
        child: widget.book.cachedCover != null ? Image.file(widget.book.cachedCover!) : Image.asset('assets/generic_book_cover.png'));
  }

  Widget _getSeries() {
    return widget.book.series != null
        ? RichText(
            text: TextSpan(style: Theme.of(context).textTheme.bodyLarge, children: [
            TextSpan(
                text: widget.book.series!.series,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _openCollection(widget.book.series!.getBookCollection());
                  }),
            TextSpan(text: ' #${widget.book.seriesIndex}'),
          ]))
        : const Text('');
  }

  void _openCollection(Collection? collection) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: collection!)));
  }

  Widget _getTags(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge,
            children: widget.book.tags
                    ?.mapIndexed((i, e) => TextSpan(
                        text: '${e.tag}${i < widget.book.tags!.length - 1 && i < widget.book.tags!.length ? ', ' : ''}',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _openCollection(e.getBookCollection());
                          }))
                    .toList() ??
                []));
  }
}
