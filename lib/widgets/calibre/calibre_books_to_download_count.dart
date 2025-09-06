import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/calibre_ws.dart';
import 'package:paladin/widgets/calibre/calibre_status.dart';

import '../../models/calibre_sync_data.dart';
import 'calibre_count.dart';

class CalibreBooksToDownloadCount extends ConsumerWidget {
  final String calibreUrl;
  final DateTime lastSyncDate;

  const CalibreBooksToDownloadCount({super.key, required this.calibreUrl, required this.lastSyncDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CalibreSyncData syncData = ref.watch(calibreWSProvider);

    return CalibreStatus(
      calibreUrl: calibreUrl,
      child: Center(
        child: Row(
          children: [
            Spacer(),
            Text('There are ', style: Theme.of(context).textTheme.bodyMedium),
            CalibreCount(calibreUrl: calibreUrl, checkDate: syncData.syncFromEpoch ? DateTime.fromMillisecondsSinceEpoch(0) : lastSyncDate),
            Text('/', style: Theme.of(context).textTheme.bodyMedium),
            CalibreCount(calibreUrl: calibreUrl, checkDate: DateTime.fromMillisecondsSinceEpoch(0)),
            Text(' book(s) to sync.', style: Theme.of(context).textTheme.bodyMedium),
            Spacer(),
          ],
        ),
      ),
    );
  }
}