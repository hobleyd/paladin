import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:paladin/widgets/books/book_tile_list.dart';

import '../../models/calibre_server.dart';
import '../../models/collection.dart';
import '../../models/shelf.dart';
import '../../providers/calibre_ws.dart';
import '../../repositories/calibre_server_repository.dart';
import '../books/book_table.dart';
import '../home/fatal_error.dart';

import 'calibre_books_to_download_count.dart';
import 'calibre_read_status_update_count.dart';
import 'calibre_status.dart';

class CalibreInformation extends ConsumerWidget {
  const CalibreInformation({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var calibreServerAsync = ref.watch(calibreServerRepositoryProvider);

    return calibreServerAsync.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (CalibreServer calibre) {
      var syncData = ref.watch(calibreWSProvider);

      final String formattedText = calibre.lastConnected == 0
            ? "We have no records of any prior synchronisation, sorry!"
            : "Last synchronised on ${DateFormat('MMMM d, y: H:mm').format(calibre.lastConnectedDateTime)}";
      return Column(
        children: [
          CalibreStatus(calibreUrl: syncData.calibreServer,),
          const SizedBox(height: 10),
          Text(formattedText, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          if (syncData.syncReadStatuses) ...[
            CalibreReadStatusUpdateCount(lastSyncDate: calibre.lastConnectedDateTime),
            const SizedBox(height: 10),
          ],
          CalibreBooksToDownloadCount(calibreUrl: syncData.calibreServer, lastSyncDate: calibre.lastConnectedDateTime,),
          const SizedBox(height: 10),
          Text('Click the Sync button (below) to synchronise your library!', style: Theme.of(context).textTheme.bodyMedium),
          if (syncData.syncReadStatuses) ...[
            const SizedBox(height: 30),
            Text('Books read since last update', style: Theme.of(context).textTheme.labelMedium),
            const Divider(color: Colors.black, thickness: 1),
            Expanded(
              child: BookTable(
                collection: Collection(
                  type: CollectionType.BOOK,
                  query: 'select * from books where lastRead > ? order by lastRead DESC',
                  queryArgs: [calibre.lastConnected],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}