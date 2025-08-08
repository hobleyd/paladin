import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:paladin/repositories/last_connected.dart';
import 'package:paladin/widgets/home/fatal_error.dart';

class CalibreStatus extends ConsumerWidget {
  const CalibreStatus({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var lastSyncDateAsync = ref.watch(calibreLastConnectedDateProvider);

    return lastSyncDateAsync.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (DateTime syncDate) {
      final String formattedText = syncDate.millisecondsSinceEpoch == 0
            ? "We have no records of any prior synchronisation, sorry!"
            : "You last synchronised your library on ${DateFormat('MMMM d, y: H:mm').format(syncDate)}";
        return Column(
        children: [
          Text(' $formattedText', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Click the Sync button (below) to download your books!', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
    });
  }
}