import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calibre_health.dart';
import '../../providers/calibre_dio.dart';

class CalibreStatus extends ConsumerWidget {
  final String calibreUrl;

  const CalibreStatus({super.key, required this.calibreUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var calibreWS = ref.read(calibreDioProvider(calibreUrl));

    return FutureBuilder(
      future: calibreWS.getHealth(),
      builder: (BuildContext ctx, AsyncSnapshot<CalibreHealth> snapshot) {
        return snapshot.connectionState != ConnectionState.done
            ? Text('Waiting for Calibre to respond...!', style: Theme.of(context).textTheme.bodyMedium)
            : snapshot.error != null
            ? Text('Error communicating with Calibre on $calibreUrl:\n${snapshot.error}')
            : Text('Calibre is: ${snapshot.data!.status} on $calibreUrl.', style: Theme.of(context).textTheme.bodyMedium);
      },
    );
  }
}