import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifiers/library_db.dart';
import 'widgets/paladin.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<LibraryDB>(create: (_) => LibraryDB()),
      ],
      child: MaterialApp(
      title: 'Paladin',
      theme: ThemeData(
        fontFamily: 'Georgia',
        inputDecorationTheme: const InputDecorationTheme(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            errorBorder:   UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal, width: 2))),
        primarySwatch: Colors.teal,
        splashColor: Colors.blueGrey,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 12.0, fontFamily: 'Hind'),
          bodyLarge : TextStyle(fontSize: 12.0, fontFamily: 'Hind', fontWeight: FontWeight.bold),
        ),
      ),
      home: Paladin())));
}
