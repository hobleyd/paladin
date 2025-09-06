import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/navigator_stack.dart';

import '../../models/collection.dart';
import '../../screens/book_list.dart';
import '../../screens/collection_list.dart';
import '../../screens/settings.dart';

class MenuButton extends ConsumerWidget {
  final int count;
  final String label;
  final Collection collection;

  const MenuButton({super.key, required this.label, required this.count, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: TextButton(
        onPressed: () => _navigateToCollection(context, ref, collection),
        style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white), foregroundColor: WidgetStatePropertyAll(Colors.black)),
        child: Text('$label\n($count)', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall,),
      ),
    );
  }

  Future _navigateToCollection(BuildContext context, WidgetRef ref, Collection collection) async {
    switch (collection.type) {
      case CollectionType.BOOK:
        ref.read(navigatorStackProvider.notifier).push(context, "books_button", MaterialPageRoute(builder: (context) => BookList(collection: collection)));
        return;
      case CollectionType.SETTINGS:
        ref.read(navigatorStackProvider.notifier).push(context, "settings_button", MaterialPageRoute(builder: (context) => const Settings()));
        return;
      default:
        ref.read(navigatorStackProvider.notifier).push(context, "collection_button", MaterialPageRoute(builder: (context) => CollectionList(collection: collection)));
        return;
    }
  }
}