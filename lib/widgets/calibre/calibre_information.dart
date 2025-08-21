import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:paladin/providers/calibre_ws.dart';
import 'package:paladin/widgets/calibre/calibre_books_to_download_count.dart';

import '../../models/calibre_server.dart';
import '../../repositories/calibre_server_repository.dart';
import '../home/fatal_error.dart';

import 'calibre_read_status_update_count.dart';
import 'calibre_status.dart';

class CalibreInformation extends ConsumerWidget {
  const CalibreInformation({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var calibreServer = ref.watch(calibreServerRepositoryProvider);
    var syncData = ref.watch(calibreWSProvider);

    return calibreServer.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (CalibreServer calibreServer) {
      final String formattedText = calibreServer.lastConnected == 0
            ? "We have no records of any prior synchronisation, sorry!"
            : "Last synchronised on ${DateFormat('MMMM d, y: H:mm').format(calibreServer.lastConnectedDateTime)}";
        return Column(
        children: [
          CalibreStatus(),
          const SizedBox(height: 10),
          Text(formattedText, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          if (syncData.syncReadStatuses) ...[
            CalibreReadStatusUpdateCount(lastSyncDate: calibreServer.lastConnectedDateTime),
            const SizedBox(height: 10),
          ],
          CalibreBooksToDownloadCount(lastSyncDate: calibreServer.lastConnectedDateTime,),
          const SizedBox(height: 10),
          Text('Click the Sync button (below) to download your books!', style: Theme.of(context).textTheme.bodyMedium),
        ],
      );
    });
  }
}