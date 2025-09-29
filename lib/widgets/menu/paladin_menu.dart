import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/database/library_db.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../models/tag.dart';
import '../../providers/navigator_stack.dart';
import '../../screens/book_list.dart';
import '../../screens/calibresync.dart';
import '../../utils/math_constants.dart';

class PaladinMenu extends ConsumerWidget {
  const PaladinMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      itemBuilder: (BuildContext context) =>
      <PopupMenuEntry<String>>[
        if (Platform.isAndroid) PopupMenuItem<String>(value: 'backup',   child: Text('Backup DB', style: Theme.of(context).textTheme.bodyMedium),),
        if (Platform.isAndroid) PopupMenuDivider(),
        PopupMenuItem<String>(value: 'future',   child: Text(Tag.futureReads, style: Theme.of(context).textTheme.bodyMedium),),
        PopupMenuItem<String>(value: 'history',  child: Text('Reading History', style: Theme.of(context).textTheme.bodyMedium),),
        PopupMenuItem<String>(value: 'sync',     child: Text('Synchronise Library', style: Theme.of(context).textTheme.bodyMedium),),
        if (Platform.isAndroid) PopupMenuItem<String>(value: 'settings', child: Text('System Settings', style: Theme.of(context).textTheme.bodyMedium),),
        PopupMenuDivider(),
        if (Platform.isAndroid) PopupMenuItem<String>(value: 'exit', child: Text('Exit', style: Theme.of(context).textTheme.bodyMedium),),
      ],
      onSelected: (String? item) => _selectMenuItem(context, ref, item),
    );
  }

  void _selectMenuItem(BuildContext context, WidgetRef ref, String? item) {
    if (item != null) {
      switch (item) {
        case 'backup':
          final params = ShareParams(
            text: 'Paladin Database',
            files: [XFile(ref.read(libraryDBProvider.notifier).dbPath)],
          );

          SharePlus.instance.share(params);
          break;
        case 'future':
          ref.read(navigatorStackProvider.notifier).push(
            context,
            "future_reads",
            MaterialPageRoute(
              builder: (context) => BookList(
                collection: Collection(
                    type: CollectionType.BOOK,
                    query: Shelf.shelfQuery[CollectionType.TAG]!,
                    queryArgs: [Tag.futureReads, maxInt],
                ),
              ),
            ),
          );
          break;
        case 'history':
          ref.read(navigatorStackProvider.notifier).push(
            context,
            "reading_history",
            MaterialPageRoute(
              builder: (context) => BookList(
                collection: Collection(
                    type: CollectionType.BOOK,
                    query: Shelf.shelfQuery[CollectionType.CURRENT]!,
                    queryArgs: [maxInt],
                ),
              ),
            ),
          );
          break;
        case 'settings':
          AppSettings.openAppSettings(type: AppSettingsType.generalSettings);
          break;
        case 'sync':
          ref.read(navigatorStackProvider.notifier).push(context, "calibre_sync", MaterialPageRoute(builder: (context) => CalibreSync()));
          break;
        case 'exit':
          exit(0);
          break;
      }
    }
  }
}