import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/calibre_ws.dart';

import '../../models/calibre_health.dart';
import '../../models/calibre_sync_data.dart';
import '../../providers/calibre_dio.dart';
import 'calibre_count.dart';

class CalibreStatus extends ConsumerWidget {
  final DateTime lastSyncDate;
  const CalibreStatus({super.key, required this.lastSyncDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var calibre = ref.read(calibreDioProvider);
    CalibreSyncData syncData = ref.watch(calibreWSProvider);

    return FutureBuilder(
        future: calibre.getHealth(),
        builder: (BuildContext ctx, AsyncSnapshot<CalibreHealth> snapshot) {
          return snapshot.connectionState != ConnectionState.done
              ? Text('Waiting for Calibre to respond...!', style: Theme.of(context).textTheme.bodyMedium)
              : snapshot.error != null
              ? Text('Error communicating with Calibre: ${snapshot.error}')
              : Center(
                  child: Row(
                    children: [
                      Spacer(),
                      Text('Calibre status is: ${snapshot.data!.status}. There are ', style: Theme.of(context).textTheme.bodyMedium),
                      CalibreCount(checkDate: syncData.syncFromEpoch ? DateTime.fromMillisecondsSinceEpoch(0) : lastSyncDate),
                      Text('/', style: Theme.of(context).textTheme.bodyMedium),
                      CalibreCount(checkDate: DateTime.fromMillisecondsSinceEpoch(0)),
                      Text(' books to sync.', style: Theme.of(context).textTheme.bodyMedium),
                      Spacer(),
                    ],
                  ),
                );
        },
    );
  }
}