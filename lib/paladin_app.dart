import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/paladin_theme.dart';
import 'screens/paladin.dart';
import 'utils/update.dart';

class PaladinApp extends ConsumerWidget {
  const PaladinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Platform.isAndroid) {
      checkForUpdate();
    }
    return MaterialApp(
      title: 'Paladin',
      home: Paladin(),
      theme: ref.watch(paladinThemeProvider),
    );
  }
}
