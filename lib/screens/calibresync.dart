import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_screen_on/keep_screen_on.dart';


import '../interfaces/sync_with_calibre.dart';
import '../models/json_book.dart';
import '../repositories/calibre_ws.dart';
import '../providers/calibre_book_provider.dart';
import '../widgets/calibre/calibre_progress_bar.dart';
import '../widgets/calibre/calibre_status.dart';
import '../widgets/calibre/calibre_sync_button.dart';
import '../widgets/calibre/calibre_book_list.dart';

class CalibreSync extends ConsumerStatefulWidget {
  const CalibreSync({super.key, });

  @override
  ConsumerState<CalibreSync> createState() => _CalibreSync();
}

class _CalibreSync extends ConsumerState<CalibreSync> implements SyncWithCalibre {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      KeepScreenOn.turnOn();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Synchronise Library')),
      body: Column(
        children: [
          Expanded(child: _getStatusList()),
          CalibreProgressBar(),
          CalibreSyncButton(processing: _processing, sync: this),
        ],
      ),
    );
  }

  Widget _getStatusList() {
    List<JSONBook> errors = ref.watch(calibreBookProvider(BooksType.error));

    return _processing
        ? CalibreBookList(bookType: BooksType.processed,)
        : errors.isNotEmpty
            ? CalibreBookList(bookType: BooksType.error,)
            : Padding(padding: const EdgeInsets.only(top: 50, bottom: 50), child: CalibreStatus());
  }

  @override
  Future<void> syncWithCalibre() async {
    setState(() {
      _processing = true;
    });

    await Isolate.run(() {
      ref.read(calibreWSProvider.notifier).getBooks();
    });

    setState(() {
      _processing = false;
    });
  }
}