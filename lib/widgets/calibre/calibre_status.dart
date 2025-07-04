import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:paladin/repositories/calibre_ws.dart';

class CalibreStatus extends ConsumerWidget {
  const CalibreStatus({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int lastSyncDate = ref.read(calibreWSProvider).syncDate;

    final DateTime lastSynced = DateTime.fromMillisecondsSinceEpoch(lastSyncDate * 1000);
    final String formattedDate = DateFormat('MMMM d, y: H:mm').format(lastSynced);
    return Column(
      children: [
        Text('You last synchronised your library on $formattedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('Click the Sync button to download your books!', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

}