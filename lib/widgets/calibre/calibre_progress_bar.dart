import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calibre_sync_data.dart';
import '../../providers/calibre_ws.dart';

class CalibreProgressBar extends ConsumerWidget {
  const CalibreProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CalibreSyncData syncData = ref.watch(calibreWSProvider);

    return Column(children: [
      const Divider(thickness: 1, height: 3, color: Colors.black),
      if (syncData.progress > 0) ...[
        LinearProgressIndicator(value: syncData.progress, semanticsLabel: 'Books Saved to Database'),
        const Divider(thickness: 1, height: 3, color: Colors.black),
      ]
    ]);
  }

}