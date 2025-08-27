import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calibre_health.dart';
import '../../providers/calibre_dio.dart';

class CalibreStatus extends ConsumerWidget {
  final String calibreUrl;
  final Widget? child;

  const CalibreStatus({super.key, required this.calibreUrl, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var calibreWS = ref.read(calibreDioProvider(calibreUrl));

    return FutureBuilder(
      future: calibreWS.getHealth(),
      builder: (BuildContext ctx, AsyncSnapshot<CalibreHealth> snapshot) {
        if (snapshot.error != null) {
          debugPrint('Error communicating with Calibre:\n${snapshot.error}');
        }
        return snapshot.connectionState != ConnectionState.done
            ? Text('Waiting for Calibre to respond...!', style: Theme.of(context).textTheme.bodyMedium)
            : snapshot.error != null
              ? calibreUrl.isEmpty
                ? Text("Can't find Calibre running on local network; are you running the server?", style: Theme.of(context).textTheme.bodyMedium)
                : Text('Error communicating with Calibre on $calibreUrl', style: Theme.of(context).textTheme.bodyMedium)
              : child == null
                ? Text('Calibre is: ${snapshot.data!.status} on $calibreUrl.', style: Theme.of(context).textTheme.bodyMedium)
                : child!;
      },
    );
  }
}