import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../models/book.dart';
import '../../providers/book_provider.dart';

class Blurb extends ConsumerWidget {
  final String bookUuid;
  final ScrollController _scrollController = ScrollController();

  Blurb({super.key, required this.bookUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String label = "I know you might expect a back-cover description, but it's a mystery; perhaps you need to read the book to find out what it's about!";

    Book? book = ref.watch(bookProviderProvider(bookUuid));
    if (book == null) {
      return const Text(label);
    }

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