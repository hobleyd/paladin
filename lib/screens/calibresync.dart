import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

import '../models/calibre_sync_data.dart';
import '../models/json_book.dart';
import '../providers/calibre_ws.dart';
import '../providers/calibre_book_provider.dart';
import '../widgets/calibre/calibre_progress_bar.dart';
import '../widgets/calibre/calibre_information.dart';
import '../widgets/calibre/calibre_sync_button.dart';
import '../widgets/calibre/calibre_book_list.dart';
import '../widgets/calibre/sync_notifications.dart';

class CalibreSync extends ConsumerWidget {
  const CalibreSync({super.key, });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Platform.isAndroid || Platform.isIOS) {
      KeepScreenOn.turnOn();
    }

    CalibreSyncData calibre = ref.watch(calibreWSProvider);
    List<JSONBook> errors = ref.watch(calibreBookProvider(BooksType.error));

    return Scaffold(
      appBar: AppBar(title: const Text('Synchronise Library')),
      body: Column(
        children: [
          calibre.syncState == CalibreSyncState.PROCESSING || calibre.syncState == CalibreSyncState.REVIEW
              ? Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: calibre.syncState == CalibreSyncState.PROCESSING
                            ? CalibreBookList(bookType: BooksType.processed)
                            : CalibreBookList(bookType: BooksType.error),
                      ),
                      Expanded(child: SyncNotifications()),
                    ],
                  ),
                )
              : Expanded(child: Padding(padding: const EdgeInsets.only(top: 50, bottom: 50), child: CalibreInformation())),
          CalibreProgressBar(),
          CalibreSyncButton(),
        ],
      ),
    );
  }
}