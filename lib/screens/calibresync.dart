import'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:paladin/providers/paladin_theme.dart';
import 'package:paladin/providers/progress_provider.dart';
import 'package:paladin/providers/status_provider.dart';

import '../models/json_book.dart';
import '../repositories/calibre_ws.dart';

class CalibreSync extends ConsumerStatefulWidget {
  final KeyboardCallback keyHandler;
  final TagHandler tagHandler;
  final FileOfInterest? paneEntity;

  const CalibreSync({Key? key, required this.keyHandler, required this.tagHandler, this.paneEntity, }) : super(key: key);

  @override
  ConsumerState<CalibreSync> createState() => _CalibreSync();
}

class _CalibreSync extends ConsumerState<CalibreSync> {
  final ScrollController scrollController = ScrollController();
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      KeepScreenOn.turnOn();
    }

    return Scaffold(
        appBar: AppBar(title: const Text('Synchronise Library')),
        body: Column(children: [
          Expanded(child: _getStatusList()),
          _getProgressBar(ref),
          _getSyncButton(),
        ]));
  }

  Widget _getBookList(List<JSONBook> list) {
    return Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
                controller: scrollController,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return ListTile(subtitle: Text(list[index].Author), title: Text(list[index].Title));
                  },
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                )));
  }

  Widget _getProgressBar(WidgetRef ref) {
    double progress = ref.watch(progressProvider);

    return Column(children: [
      const Divider(thickness: 1, height: 3, color: Colors.black),
      if (progress > 0) ...[
        LinearProgressIndicator(value: progress, semanticsLabel: 'Books Saved to Database'),
        const Divider(thickness: 1, height: 3, color: Colors.black),
      ]
    ]);

    // return progress > 0
    //     ? Column(children: [
    //         const Divider(thickness: 1, height: 3, color: Colors.black),
    //         LinearProgressIndicator(value: progress, semanticsLabel: 'Books Saved to Database'),
    //         const Divider(thickness: 1, height: 3, color: Colors.black),
    //       ])
    //     : const Divider(thickness: 1, height: 3, color: Colors.black);
  }

  Widget _getStatus() {
    final DateTime lastSynced = DateTime.fromMillisecondsSinceEpoch(_calibre.syncDate * 1000);
    final String formattedDate = DateFormat('MMMM d, y: H:mm').format(lastSynced);
    return Column(children: [
      Text('You last synchronised your library on $formattedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      const Text('Click the Sync button to download your books!', style: TextStyle(fontWeight: FontWeight.bold))]);
  }

  Widget _getStatusList() {
    return _processing
        ? _getBookList(_calibre.processedBooks)
        : _calibre.errors.isNotEmpty
            ? _getBookList(_calibre.errors)
            : Padding(padding: const EdgeInsets.only(top: 50, bottom: 50), child: _getStatus());
  }

  Widget _getSyncButton(WidgetRef ref) {
    if (!_processing) {
      return IntrinsicWidth(child: Row(children: [
        ElevatedButton(
          onPressed: () => _syncWithCalibre(context),
          style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.white, disabledForegroundColor: Colors.black),
          child: Text(_calibre.errors.isEmpty ? 'Sync' : 'Re-Sync', textAlign: TextAlign.center),
        ),
        const SizedBox(),
        Flexible(fit: FlexFit.loose, child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            selected: _calibre.syncFromEpoch,
            title: const Text('From Epoch?'),
            onChanged: (bool? checked) {
              _calibre.setSyncFromEpoch(checked);
            },
            value: _calibre.syncFromEpoch)),
      ]));
    }

    String status = ref.watch(statusProvider);
    ThemeData theme = ref.watch(paladinThemeProvider);
    return Text(status, style: theme.textTheme.titleLarge, textAlign: TextAlign.center);
  }

  Future<void> _syncWithCalibre(BuildContext context) async {
    setState(() {
      _processing = true;
    });

    await Isolate.run(() {
      calibreProvider().getBooks();
    });

    setState(() {
      _processing = false;
    });
  }
}