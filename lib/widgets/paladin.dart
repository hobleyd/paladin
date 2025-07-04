import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intersperse/intersperse.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:paladin/models/collection.dart';

import '../models/book.dart';
import '../models/shelf.dart';
import '../repositories/calibre_ws.dart';
import '../database/library_db.dart';

import '../screens/home_screen.dart';
import 'books/bookshelf.dart';
import 'books/book_tile.dart';
import '../screens/calibresync.dart';
import 'menu/menu_buttons.dart';
import 'menu/paladin_menu.dart';

class Paladin extends ConsumerWidget {
  late LibraryDB _library;
  Paladin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: HomeScreen(),
        ),
      ),
    );
  }
}
