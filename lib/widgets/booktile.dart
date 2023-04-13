import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';

import '../models/book.dart';
import 'backcover.dart';

class BookTile extends StatefulWidget {
  final Book book;
  const BookTile({Key? key, required this.book}) : super(key: key);

  @override
  _BookTile createState() => _BookTile();
}

class _BookTile extends State<BookTile> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => _openBackCover(widget.book),
        child: Row(children: [
      Container(padding: const EdgeInsets.only(left: 6.0, right: 8.0, top: 4.0, bottom: 2.0), child: _getBookCover(),),
      Expanded(child: Column(
          children: [
        Text(widget.book.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        _getSeries(),
        _getAuthors(),
        widget.book.description != null
            ? Expanded(
                child: Scrollbar(
                    controller: _scrollController, child: SingleChildScrollView(controller: _scrollController, child: HtmlWidget(widget.book.description!))))
            : const Text("I know you might expect a back-cover description, but it's a mystery; perhaps you need to read the book to find out what it's about!"),
      ])),
    ]));
  }

  Widget _getBookCover() {
    if (widget.book.cachedCover != null) {
      return Image.file(widget.book.cachedCover!);
    }
    return Image.asset('assets/generic_book_cover.png');
  }

  Widget _getLastRead() {
    if (widget.book.lastRead != null) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(widget.book.lastRead! * 1000);
      String formattedDate = DateFormat('yyyy-mmm-dd - kk:mm').format(dt);
      return Text('Last read on: $formattedDate');
    } else {
      return const Text('Not (yet) read!');
    }
  }

  Widget _getSeries() {
    return widget.book.series != null
        ? Text('${widget.book.series!.series} #${widget.book.seriesIndex}', style: const TextStyle(fontWeight: FontWeight.bold))
        : const Text('');
  }

  Widget _getAuthors() {
    String authors = '';
    for (var author in widget.book.authors!) {
      if (authors.isNotEmpty) {
        authors != ', ';
      }
      authors += author.name;
    }

    return Text(authors, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  void _openBackCover(Book book) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BackCover(book: book)));
  }
}
