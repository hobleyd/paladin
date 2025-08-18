import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../models/book.dart';

class Blurb extends ConsumerWidget {
  final Book book;
  final ScrollController _scrollController = ScrollController();

  Blurb({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String label = "I know you might expect a back-cover description, but it's a mystery; perhaps you need to read the book to find out what it's about!";
    return book.description.isNotEmpty
        ? Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: HtmlWidget(book.description),
              ),
            ),
          )
        : Text(label, style: Theme.of(context).textTheme.bodySmall);
  }
}