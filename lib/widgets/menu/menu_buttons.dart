import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/models/version_check.dart';
import 'package:paladin/repositories/authors_repository.dart';
import 'package:paladin/repositories/shelves_repository.dart';

import '../../models/author.dart';
import '../../models/book.dart';
import '../../models/collection.dart';
import '../../models/series.dart';
import '../../models/tag.dart';
import '../../providers/update.dart';
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
    int settingsCount = 1 + (ref.watch(shelvesRepositoryProvider).value?.length ?? 0);

    VersionCheck? versions = ref.watch(updateProvider).value;
    String settingsLabel = 'Settings';
    if (versions != null) {
      if (versions.hasUpdate) {
        settingsLabel = '$settingsLabel (!)';
        settingsCount++;
      }
    }
    return Ink(
        child: IntrinsicHeight(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MenuButton(label: 'Books', count: booksCount, collection: Collection(type: CollectionType.BOOK, query: Book.booksQuery, queryArgs: ['%'])),
                  const VerticalDivider(color: Colors.black, thickness: 1),
                  MenuButton(label: 'Authors', count: authorCount, collection: Collection(type: CollectionType.AUTHOR, query: Author.authorsQuery, queryArgs: ['%'])),
                  const VerticalDivider(color: Colors.black, thickness: 1),
                  MenuButton(label: 'Series', count: seriesCount, collection: Collection(type: CollectionType.SERIES, query: Series.seriesQuery, queryArgs: ['%'])),
                  const VerticalDivider(color: Colors.black, thickness: 1),
                  MenuButton(label: 'Tags', count: tagsCount, collection: Collection(type: CollectionType.TAG, query: Tag.tagsQuery, queryArgs: ['%', tagsCount])),
                  const VerticalDivider(color: Colors.black, thickness: 1),
                  MenuButton(label: settingsLabel, count: settingsCount, collection: Collection(type: CollectionType.SETTINGS, query: "",)),
                ],
            ),
        ),
    );
  }
}
