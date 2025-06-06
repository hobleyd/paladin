import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:paladin/widgets/paladinmenu.dart';

import '../models/book.dart';
import 'backcover.dart';

class BookTile extends StatefulWidget {
  final Book book;
  final bool showMenu;
  const BookTile({Key? key, required this.book, required this.showMenu}) : super(key: key);

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
          Container(
            padding: const EdgeInsets.only(left: 6.0, right: 8.0, top: 4.0, bottom: 2.0),
            child: _getBookCover(),
          ),
          Expanded(child: Stack(children: [
            Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                child: Center(child: Column(children: _getTitleFields(),))),
            Align(
                alignment: Alignment.topRight,
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  widget.showMenu ? PaladinMenu() : const Text(''),
                  _getLastRead(),
                ])),
          ])),
        ]));
  }

  Widget _getBookCover() {
    if (widget.book.cachedCover != null && widget.book.cachedCover!.existsSync()) {
      return Image.file(widget.book.cachedCover!);
    }
    return Image.asset('assets/generic_book_cover.png');
  }

  Widget _getAuthors() {
    String authors = '';
    for (var author in widget.book.authors!) {
      if (authors.isNotEmpty) {
        authors += ', ';
      }
      authors += author.getAuthorNameNormalised();
    }

    return Text(authors, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall);
  }

  Widget _getDescription() {
    const String label = "I know you might expect a back-cover description, but it's a mystery; perhaps you need to read the book to find out what it's about!";
    return widget.book.description != null
        ? Expanded(child:
            Scrollbar(controller: _scrollController, child: SingleChildScrollView(controller: _scrollController, child: HtmlWidget(widget.book.description!))))
        : Text(label, style: Theme.of(context).textTheme.labelSmall);
  }

  Widget _getLastRead() {
    if (widget.book.lastRead != null) {
      final DateTime lastRead = DateTime.fromMillisecondsSinceEpoch(widget.book.lastRead! * 1000);
      final String formattedDate = DateFormat('MMMM d, y').format(lastRead);
      return Text('Last read: $formattedDate', style: Theme.of(context).textTheme.bodySmall);
    } else {
      return Text('Not (yet) read!', style: Theme.of(context).textTheme.bodySmall);
    }
  }

  Widget _getSeries() {
    return Text('${widget.book.series!.getSeriesNameNormalised()} #${widget.book.seriesIndex}', style: Theme.of(context).textTheme.labelSmall);
  }

  Widget _getTitle() {
    return Text(widget.book.title, style: Theme.of(context).textTheme.labelSmall);
  }

  List<Widget> _getTitleFields() {
    List<Widget> widgets =     [
      _getTitle(),
      const SizedBox(height: 3),
      ];

    if (widget.book.series != null) {
      widgets.add(_getSeries());
      widgets.add(const SizedBox(height: 3));
    }

    widgets.add(_getAuthors());
    widgets.add(const SizedBox(height: 6));
    widgets.add(_getDescription());

    return widgets;
  }

  void _openBackCover(Book book) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BackCover(book: book)));
  }
}
