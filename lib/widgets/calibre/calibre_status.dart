import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/repositories/calibre_server_repository.dart';

import '../../models/calibre_health.dart';
import '../../providers/calibre_dio.dart';
import '../../providers/calibre_network_service.dart';

class CalibreStatus extends ConsumerWidget {
  const CalibreStatus({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var calibre = ref.read(calibreDioProvider);
    var calibreServer = ref.watch(calibreServerRepositoryProvider);

    return FutureBuilder(
        future: calibre.getHealth(),
        builder: (BuildContext ctx, AsyncSnapshot<CalibreHealth> snapshot) {
          return snapshot.connectionState != ConnectionState.done
              ? Text('Waiting for Calibre to respond...!', style: Theme.of(context).textTheme.bodyMedium)
              : snapshot.error != null
              ? Text('Error communicating with Calibre on ${calibreServer.value?.calibreServer}:\n${snapshot.error}')
              : Text('Calibre is: ${snapshot.data!.status} on ${calibreServer.value?.calibreServer}.', style: Theme.of(context).textTheme.bodyMedium);
        },
    );
  }
}