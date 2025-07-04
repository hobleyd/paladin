import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/progress_provider.dart';

class CalibreProgressBar extends ConsumerWidget {
  const CalibreProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double progress = ref.watch(progressProvider);

    return Column(children: [
      const Divider(thickness: 1, height: 3, color: Colors.black),
      if (progress > 0) ...[
        LinearProgressIndicator(value: progress, semanticsLabel: 'Books Saved to Database'),
        const Divider(thickness: 1, height: 3, color: Colors.black),
      ]
    ]);
  }

}