import 'package:flutter/material.dart';

import 'library_db.dart';

class LibraryNotifier extends ChangeNotifier {
  late LibraryDB _library;

  int? getTableCount(String table) {
    return _library.tableCount[table];
  }

  LibraryNotifier() {
    _library = LibraryDB();
    notifyListeners();
  }
}