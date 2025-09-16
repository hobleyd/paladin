import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../database/library_db.dart';
import '../../models/calibre_book_count.dart';
import '../../models/calibre_server.dart';
import '../../models/calibre_update_list.dart';
import '../../providers/calibre_dio.dart';
import '../../providers/calibre_ws.dart';
import '../../repositories/calibre_server_repository.dart';
import '../books/book_table.dart';
import '../home/fatal_error.dart';

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
      var calibreService = ref.read(calibreDioProvider(syncData.calibreServer));

      final String formattedText = calibre.lastConnected == 0
            ? "We have no records of any prior synchronisation, sorry!"
            : "Last synchronised on ${DateFormat('MMMM d, y: H:mm').format(calibre.lastConnectedDateTime)}";
      return Column(
        children: [
          CalibreStatus(calibreUrl: syncData.calibreServer,),
          const SizedBox(height: 10),
          Text(formattedText, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text('Click the Sync button (below) to synchronise your library!', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 30),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 40, right: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: BookTable(label: 'book(s) to upload...', future: _getBooksToUpload(ref, syncData.syncReadStatuses, syncData.syncFromEpoch, calibre.lastConnected))),
                SizedBox(width: 10,),
                Expanded(child: BookTable(label: 'book(s) to download...', future: calibreService.getCount(syncData.syncFromEpoch ? 0 : calibre.lastConnected, 30))),
              ],
            ),
          ),
          ],
      );
    });
  }

  Future<CalibreBookCount> _getBooksToUpload(WidgetRef ref, bool syncReadStatuses, bool syncFromEpoch, int lastConnected) async {
    var libraryDb = ref.read(libraryDBProvider.notifier);

    // Only query DB, if we want to sync the data!
    if (!syncReadStatuses) {
      return CalibreBookCount(count: 0, books: []);
    }

    List<Map<String, dynamic>> results = await libraryDb.rawQuery(
        sql: '''
            SELECT title, authors.name as author, lastRead, COUNT(*) OVER() AS count
              FROM books, authors, book_authors
             WHERE books.uuid = book_authors.bookId and authors.id = book_authors.authorId and lastRead > ?
          ORDER BY lastRead DESC
        ''',
        args: [syncFromEpoch ? 0 : lastConnected]);

    if (results.isEmpty) {
      return CalibreBookCount(count: 0, books: []);
    }

    return CalibreBookCount(
      count: results[0]['count'],
      books: [for (var row in results)
        CalibreUpdateList(
          title: row['title'],
          author: row['author'],
          lastModified: row['lastRead'],
        )
      ],
    );
  }
}