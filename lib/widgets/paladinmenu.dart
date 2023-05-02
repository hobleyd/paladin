import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/collection.dart';
import '../models/tag.dart';
import '../notifiers/calibre_ws.dart';
import '../notifiers/library_db.dart';
import 'booklist.dart';
import 'calibresync.dart';
import 'collectionlist.dart';

class PaladinMenu extends StatelessWidget {
  static const TextStyle _style = TextStyle(fontSize: 10);
  late LibraryDB library;
  late BuildContext context;

  PaladinMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    library = Provider.of<LibraryDB>(context, listen: false);
    this.context = context;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      itemBuilder: (BuildContext context) =>
      <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'future', child: Text('Future Reads', style: _style),),
        const PopupMenuItem<String>(value: 'sync', child: Text('Synchronise Library', style: _style),),
      ],
      onSelected: (String? item) => _selectMenuItem(context, item),
    );
  }

  void _selectMenuItem(BuildContext context, String? item) {
    if (item != null) {
      switch (item) {
        case 'future':
          _navigateToTag();
          break;
        case 'sync':
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                  create: (context) => CalibreWS(context),
                  builder: (context, child) => const CalibreSync()))).then((value) => library.updateFields(null));
          break;
      }
    }
  }

  Future _navigateToTag() async {
    Tag? futureReads = await library.getTag('Future Reads');
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BookList(collection: futureReads!.getBookCollection()!)));
    }
  }
}