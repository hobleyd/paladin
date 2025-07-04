import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/tag.dart';
import '../../database/library_db.dart';
import '../../screens/book_list.dart';
import '../../screens/calibresync.dart';

class PaladinMenu extends ConsumerWidget {
  static const TextStyle _style = TextStyle(fontSize: 10);
  late LibraryDB library;

  PaladinMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      itemBuilder: (BuildContext context) =>
      <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'future', child: Text('Future Reads', style: _style),),
        const PopupMenuItem<String>(value: 'sync', child: Text('Synchronise Library', style: _style),),
      ],
      onSelected: (String? item) => _selectMenuItem(context, item),
    );
  }

  void _selectMenuItem(BuildContext context, String? item) {
    if (item != null) {
      switch (item) {
        case 'future':
          _navigateToTag(context);
          break;
        case 'sync':
          Navigator.push(context, MaterialPageRoute(builder: (context) => CalibreSync()));
          break;
      }
    }
  }

  Future _navigateToTag(BuildContext context) async {
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: Tag(tag: 'Future Reads'))));
    }
  }
}