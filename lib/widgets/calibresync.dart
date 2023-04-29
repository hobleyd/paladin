import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/json_book.dart';
import '../notifiers/calibre_ws.dart';

class CalibreSync extends StatefulWidget {
  const CalibreSync({Key? key}) : super(key: key);

  @override
  _CalibreSync createState() => _CalibreSync();
}

class _CalibreSync extends State<CalibreSync> {
  late CalibreWS _calibre;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<CalibreWS>(builder: (context, model, child) {
      _calibre = model;

      return Scaffold(
          appBar: AppBar(title: const Text('Calibre Sync')),
          body: Column(children: [
            _calibre.httpStatus.isEmpty
                ? Expanded(child: _getStatusList())
                : Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 50),
                    child: Text('Error syncing: ${_calibre.httpStatus}', style: const TextStyle(fontWeight: FontWeight.bold))),
            _getProgressBar(),
            _getSyncButton(),
          ]));
    });
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

  Widget _getProgressBar() {
    if (_calibre.progress > 0) {
      return Column(
        children: [
          const Divider(thickness: 1, height: 3, color: Colors.black),
          LinearProgressIndicator(value: _calibre.progress, semanticsLabel: 'Books Saved to Database'),
          const Divider(thickness: 1, height: 3, color: Colors.black),
        ]);
    }
    return const Divider(thickness: 1, height: 3, color: Colors.black);
  }

  Widget _getStatus() {
    final DateTime lastSynced = DateTime.fromMillisecondsSinceEpoch(_calibre.syncDate * 1000);
    final String formattedDate = DateFormat('MMMM d y H:m').format(lastSynced);
    return Column(children: [
      Text('You last synchronised your library on $formattedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      const Text('Click the Sync button to download your books!', style: TextStyle(fontWeight: FontWeight.bold))]);
  }

  Widget _getStatusList() {
    return _calibre.processing
        ? _getBookList(_calibre.processedBooks)
        : _calibre.errors.isNotEmpty
            ? _getBookList(_calibre.errors)
            : Padding(padding: const EdgeInsets.only(top: 50, bottom: 50), child: _getStatus());
  }

  Widget _getSyncButton() {
    if (_calibre.processedBooks.isEmpty || _calibre.errors.isNotEmpty) {
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

    return Text('Syncing ${_calibre.processedBooks[0].Title} from Calibre (${_calibre.progress.toStringAsFixed(2)})', textAlign: TextAlign.center);
  }

  Future<void> _syncWithCalibre(BuildContext context) async {
    _calibre.getBooks(context);
  }
}