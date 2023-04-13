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
            ListView.builder(
              itemCount: _calibre.returnedBooks.length,
              itemBuilder: (context, index) {
                return ListTile(subtitle: Text(_calibre.returnedBooks[index].Author), title: Text(_calibre.returnedBooks[index].Title));
              },
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
            ),
            _getProgressBar(),
            _getSyncButton(),
          ]));
    });
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
    return Center(child: Row(children: [
      Flexible(child: ElevatedButton(
        onPressed: () => _syncWithCalibre(context),
        style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.white, disabledForegroundColor: Colors.black),
        child: const Text('Sync', textAlign: TextAlign.center),
      )),
      const SizedBox(),
      Flexible(child: CheckboxListTile(
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