import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calibre_book_count.dart';
import '../../providers/calibre_dio.dart';

class CalibreCount extends ConsumerWidget {
  final String calibreUrl;
  final DateTime checkDate;

  const CalibreCount({super.key, required this.calibreUrl, required this.checkDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var calibre = ref.read(calibreDioProvider(calibreUrl));
    double timestampInSeconds = checkDate.millisecondsSinceEpoch/1000;
    return FutureBuilder(
      future: calibre.getCount(timestampInSeconds.toInt()),
      builder: (BuildContext ctx, AsyncSnapshot<CalibreBookCount> snapshot) {
        return Text(snapshot.hasData ? '${snapshot.data!.count}' : '0', style: Theme.of(context).textTheme.bodyMedium);
      },
    );
  }
}
