import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/authors_repository.dart';

import '../../models/author.dart';
import '../../models/book.dart';
import '../../models/collection.dart';
import '../../models/series.dart';
import '../../models/tag.dart';
import '../../repositories/books_repository.dart';
import '../../repositories/series_repository.dart';
import '../../repositories/tags_repository.dart';
import 'menu_button.dart';

class MenuButtons extends ConsumerWidget {
  const MenuButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int authorCount = ref.watch(authorsRepositoryProvider).value ?? 0;
    final int booksCount = ref.watch(booksRepositoryProvider).value ?? 0;
    final int seriesCount = ref.watch(seriesRepositoryProvider).value ?? 0;
    final int tagsCount = ref.watch(tagsRepositoryProvider).value ?? 0;
      return Ink(
          child: IntrinsicHeight(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MenuButton(label: 'Books', count: booksCount, collection: Collection(type: CollectionType.BOOK, count: booksCount, query: Book.booksQuery, queryArgs: ['%'])),
                    const VerticalDivider(color: Colors.black, thickness: 1),
                    MenuButton(label: 'Authors', count: authorCount, collection: Collection(type: CollectionType.AUTHOR, count: authorCount, query: Author.authorsQuery, queryArgs: ['%'])),
                    const VerticalDivider(color: Colors.black, thickness: 1),
                    MenuButton(label: 'Series', count: seriesCount, collection: Collection(type: CollectionType.SERIES, count: seriesCount, query: Series.seriesQuery, queryArgs: ['%'])),
                    const VerticalDivider(color: Colors.black, thickness: 1),
                    MenuButton(label: 'Tags', count: tagsCount, collection: Collection(type: CollectionType.TAG, count: tagsCount, query: Tag.tagsQuery, queryArgs: ['%'])),
                    const VerticalDivider(color: Colors.black, thickness: 1),
                    MenuButton(label: 'Settings', count: 4, collection: Collection(type: CollectionType.SETTINGS, query: "", count: 4)),
                  ],
              ),
          ),
      );
  }
}
