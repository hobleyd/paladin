import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paladin/database/library_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'providers/paladin_theme.dart';
import 'screens/paladin.dart';

class PaladinApp extends ConsumerWidget {
  const PaladinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Paladin',
      home: Paladin(),
      theme: ref.watch(paladinThemeProvider),
    );
  }
}
