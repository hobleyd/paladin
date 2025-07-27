import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../screens/book_list.dart';
import '../../screens/calibresync.dart';

class PaladinMenu extends ConsumerWidget {
  const PaladinMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      itemBuilder: (BuildContext context) =>
      <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: 'future',   child: Text('Future Reads', style: Theme.of(context).textTheme.bodyMedium),),
        PopupMenuItem<String>(value: 'sync',     child: Text('Synchronise Library', style: Theme.of(context).textTheme.bodyMedium),),
        if (Platform.isAndroid) PopupMenuItem<String>(value: 'settings', child: Text('System Settings', style: Theme.of(context).textTheme.bodyMedium),),
      ],
      onSelected: (String? item) => _selectMenuItem(context, item),
    );
  }

  void _selectMenuItem(BuildContext context, String? item) {
    if (item != null) {
      switch (item) {
        case 'future':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookList(
                collection: Collection(
                    type: CollectionType.BOOK,
                    query: Shelf.shelfQuery[CollectionType.TAG]!,
                    queryArgs: ['Future Reads', 100],
                    count: 100,
                ),
              ),
            ),
          );
          break;
        case 'settings':
          openAppSettings();
          break;
        case 'sync':
          Navigator.push(context, MaterialPageRoute(builder: (context) => CalibreSync()));
          break;
      }
    }
  }
}