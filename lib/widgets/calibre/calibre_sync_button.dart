import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/calibre_book_provider.dart';
import 'package:paladin/providers/calibre_ws.dart';

import '../../models/calibre_sync_data.dart';
import '../../models/json_book.dart';

class CalibreSyncButton extends ConsumerWidget {
  const CalibreSyncButton({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CalibreSyncData syncData = ref.watch(calibreWSProvider);
    if (!syncData.processing) {
      List<JSONBook> errors = ref.watch(calibreBookProvider(BooksType.error));
      return Row(
        children: [
          const Spacer(),
          const Text('Update Read Statuses?'),
          Checkbox(
            onChanged: (bool? checked) {
              ref.read(calibreWSProvider.notifier).setSyncReadStatuses(checked);
            },
            value: syncData.syncReadStatuses,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => ref.read(calibreWSProvider.notifier).synchroniseWithCalibre(),
            style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.white, disabledForegroundColor: Colors.black),
            child: Text(errors.isEmpty ? 'Sync' : 'Re-Sync', textAlign: TextAlign.center),
          ),
          const Spacer(),
          const Text('Sync from Epoch?'),
          Checkbox(
              onChanged: (bool? checked) {
                ref.read(calibreWSProvider.notifier).setSyncFromEpoch(checked);
              },
              value: syncData.syncFromEpoch,
          ),

          const Spacer(),
        ],
      );
    }
    else {
      return syncData.status == 'Completed Synchronisation'
      ? ElevatedButton(
        onPressed: () => _completeSynchronisation(ref),
        style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.white, disabledForegroundColor: Colors.black),
        child: Text('Finish'),
      )
      : Text('Synchonisation is underway...', textAlign: TextAlign.center);
    }
  }

  void _completeSynchronisation(WidgetRef ref) {
    ref.read(calibreWSProvider.notifier).setSyncFromEpoch(false);
    ref.read(calibreWSProvider.notifier).stopSynchronisation();
    ref.read(calibreBookProvider(BooksType.error).notifier).clear();
    ref.read(calibreBookProvider(BooksType.processed).notifier).clear();
  }
}