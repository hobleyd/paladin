import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifiers/calibre_ws.dart';

class CalibreSync extends StatefulWidget {
  const CalibreSync({Key? key}) : super(key: key);

  @override
  _CalibreSync createState() => _CalibreSync();
}

class _CalibreSync extends State<CalibreSync> {
  late CalibreWS _calibre;

  @override
  Widget build(BuildContext context) {
    return Consumer<CalibreWS>(builder: (context, model, child) {
      _calibre = model;

      return Scaffold(
          appBar: AppBar(title: const Text('Calibre Sync')),
          body: Column(children: [
            _calibre.httpStatus.isEmpty
                ? _getBookList()
                : Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 50),
                    child: Text('Error syncing: ${_calibre.httpStatus}', style: const TextStyle(fontWeight: FontWeight.bold))),
            _getProgressBar(),
            _getSyncButton(),
          ]));
    });
  }

  Widget _getBookList() {
    return _calibre.returnedBooks.length > 0
        ? ListView.builder(
            itemCount: _calibre.returnedBooks.length,
            itemBuilder: (context, index) {
              return ListTile(subtitle: Text(_calibre.returnedBooks[index].Author), title: Text(_calibre.returnedBooks[index].Title));
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          )
        : const Padding(
            padding: EdgeInsets.only(top: 50, bottom: 50),
            child: Text('Click the Sync button to download your books!', style: TextStyle(fontWeight: FontWeight.bold)));
  }

  Widget _getProgressBar() {
    if (_calibre.returnedBooks.isNotEmpty) {
      return Column(
        children: [
          const Divider(thickness: 1, height: 3, color: Colors.black),
          LinearProgressIndicator(value: _calibre.progress, semanticsLabel: 'Books Saved to Database'),
          const Divider(thickness: 1, height: 3, color: Colors.black),
        ]);
    }
    return const Divider(thickness: 1, height: 3, color: Colors.black);
  }

  Widget _getSyncButton() {
    return IntrinsicWidth(child: Row(children: [
      ElevatedButton(
        onPressed: () => _syncWithCalibre(context),
        style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.white, disabledForegroundColor: Colors.black),
        child: const Text('Sync', textAlign: TextAlign.center),
      ),
      const SizedBox(),
      Flexible(fit: FlexFit.loose, child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('From Epoch?'),
              onChanged: (bool? value) {
                _calibre.last_modified = 0;
              },
              value: false)),
    ]));
  }

  Future<void> _syncWithCalibre(BuildContext context) async {
    _calibre.getBooks(context);
  }
}