import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        onPressed: () => _navigateToCollection(context, collection),
        style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white), foregroundColor: WidgetStatePropertyAll(Colors.black)),
        child: Text('$label\n$count', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall,),
      ),
    );
  }

  Future _navigateToCollection(BuildContext context, Collection collection) async {
    switch (collection.type) {
      case CollectionType.BOOK:
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: collection)));
        return;
      case CollectionType.SETTINGS:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()));
        return;
      default:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionList(collection: collection)));
        return;
    }
  }
}