import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/interfaces/sync_with_calibre.dart';
import 'package:paladin/providers/calibre_book_provider.dart';
import 'package:paladin/repositories/calibre_ws.dart';

import '../../models/calibre_sync_data.dart';
import '../../models/json_book.dart';
import '../../providers/paladin_theme.dart';
import '../../providers/status_provider.dart';

class CalibreSyncButton extends ConsumerWidget {
  final bool processing;
  final SyncWithCalibre sync;

  const CalibreSyncButton({super.key, required this.processing, required this.sync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!processing) {
      List<JSONBook> errors = ref.watch(calibreBookProvider(BooksType.error));
      CalibreSyncData syncData = ref.watch(calibreWSProvider);
      return IntrinsicWidth(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () => sync.syncWithCalibre(),
              style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.white, disabledForegroundColor: Colors.black),
              child: Text(errors.isEmpty ? 'Sync' : 'Re-Sync', textAlign: TextAlign.center),
            ),
            const SizedBox(),
            Flexible(
                fit: FlexFit.loose,
                child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    selected: syncData.syncFromEpoch,
                    title: const Text('From Epoch?'),
                    onChanged: (bool? checked) {
                      ref.read(calibreWSProvider.notifier).setSyncFromEpoch(checked);
                    },
                    value: syncData.syncFromEpoch)),
          ],
        ),
      );
    }

    String status = ref.watch(statusProvider);
    ThemeData theme = ref.watch(paladinThemeProvider);
    return Text(status, style: theme.textTheme.titleLarge, textAlign: TextAlign.center);
  }
}