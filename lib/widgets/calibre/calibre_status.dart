import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calibre_health.dart';
import '../../providers/calibre_dio.dart';

class CalibreStatus extends ConsumerWidget {
  const CalibreStatus({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var calibre = ref.read(calibreDioProvider);

    return FutureBuilder(
        future: calibre.getHealth(),
        builder: (BuildContext ctx, AsyncSnapshot<CalibreHealth> snapshot) {
          return snapshot.connectionState != ConnectionState.done
              ? Text('Waiting for Calibre to respond...!', style: Theme.of(context).textTheme.bodyMedium)
              : snapshot.error != null
              ? Text('Error communicating with Calibre: ${snapshot.error}')
              : Text('Calibre status is: ${snapshot.data!.status}.', style: Theme.of(context).textTheme.bodyMedium);
        },
    );
  }
}