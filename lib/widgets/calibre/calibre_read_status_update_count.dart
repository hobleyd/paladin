import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/database/library_db.dart';
import 'package:paladin/providers/calibre_ws.dart';

import '../../models/calibre_sync_data.dart';

class CalibreReadStatusUpdateCount extends ConsumerWidget {
  final DateTime lastSyncDate;
  const CalibreReadStatusUpdateCount({super.key, required this.lastSyncDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var calibreRepository = ref.read(libraryDBProvider.notifier);
    CalibreSyncData syncData = ref.watch(calibreWSProvider);

    return FutureBuilder(
      future: calibreRepository.getCount('books',
          where: 'lastRead > 0 and lastModified > ?',
          whereArgs: [syncData.syncFromEpoch ? 0 : lastSyncDate.millisecondsSinceEpoch / 1000]),
      builder: (BuildContext ctx, AsyncSnapshot<int> count) {
        return Text('There are ${count.data} book(s) you have read since the last update!', style: Theme.of(context).textTheme.bodyMedium);
      },
    );
  }
}