import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/providers/calibre_book_provider.dart';
import 'package:paladin/providers/calibre_ws.dart';

import '../../models/calibre_server.dart';
import '../../models/calibre_sync_data.dart';
import '../../models/json_book.dart';
import '../../repositories/calibre_server_repository.dart';

class CalibreSyncButton extends ConsumerWidget {
  const CalibreSyncButton({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CalibreSyncData syncData = ref.watch(calibreWSProvider);

    if (syncData.syncState == CalibreSyncState.NOTSTARTED || syncData.syncState == CalibreSyncState.COMPLETED) {
      return Row(
        children: [
          const Spacer(),
          Text('Update Read Statuses?', style: Theme.of(context).textTheme.bodyMedium),
          Checkbox(
            onChanged: (bool? checked) {
              ref.read(calibreWSProvider.notifier).updateState(syncReadStatuses: checked);
            },
            value: syncData.syncReadStatuses,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => ref.read(calibreWSProvider.notifier).synchroniseWithCalibre(),
            style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.white, disabledForegroundColor: Colors.black),
            child: Text('Sync', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ),
          const Spacer(),
          Text('Sync from Epoch?', style: Theme.of(context).textTheme.bodyMedium),
          Checkbox(
              onChanged: (bool? checked) {
                ref.read(calibreWSProvider.notifier).updateState(syncFromEpoch: checked);
              },
              value: syncData.syncFromEpoch,
          ),

          const Spacer(),
        ],
      );
    }
    else {
      List<JSONBook> errors = ref.watch(calibreBookProvider(BooksType.error));

      return syncData.syncState == CalibreSyncState.REVIEW
          ? Row(
              children: [
                const Spacer(),
                if (errors.isNotEmpty) ...[
                  ElevatedButton(
                    onPressed: () => ref.read(calibreWSProvider.notifier).getBooks(errors),
                    style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.white, disabledForegroundColor: Colors.black),
                    child: Text('Retry', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Spacer(),
                ],
                ElevatedButton(
                  onPressed: () => _completeSynchronisation(ref),
                  style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.white, disabledForegroundColor: Colors.black),
                  child: Text('Finish', style: Theme.of(context).textTheme.bodyMedium),
                ),
                Spacer(),
              ],)
          : Text('Synchonisation is underway...', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center);
    }
  }

  void _completeSynchronisation(WidgetRef ref) {
    ref.read(calibreBookProvider(BooksType.error).notifier).clear();
    ref.read(calibreBookProvider(BooksType.processed).notifier).clear();
    ref.read(calibreWSProvider.notifier).updateState(syncFromEpoch: false, syncState: CalibreSyncState.COMPLETED);
    ref.read(calibreServerRepositoryProvider.notifier).updateServerDetails(lastConnected: CalibreServer.secondsSinceEpoch);
  }
}