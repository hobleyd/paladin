import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/calibre_server.dart';
import '../../repositories/calibre_server_repository.dart';
import '../home/fatal_error.dart';

class CalibreSyncServer extends ConsumerWidget {
  const CalibreSyncServer({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController textController = TextEditingController();
    FocusNode textNode = FocusNode();

    var calibreServer = ref.watch(calibreServerRepositoryProvider);

    return calibreServer.when(error: (error, stackTrace) {
      return FatalError(error: error.toString(), trace: stackTrace);
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    }, data: (CalibreServer calibreServer) {
      textController.text = calibreServer.calibreServer;

      return InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          isDense: true,
          labelStyle: Theme.of(context).textTheme.labelLarge,
          labelText: 'Calibre Server URL (including the https://) or leave Blank if you are running the server locally.',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        child: TextField(
          autofocus: false,
          controller: textController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          focusNode: textNode,
          onSubmitted: (_) => ref.read(calibreServerRepositoryProvider.notifier).updateServerDetails(calibreServer: textController.text),
        ),
      );
    });
  }
}