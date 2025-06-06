import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'misc/provider_logger.dart';
import 'providers/library_db.dart';
import 'providers/paladin_theme.dart';
import 'widgets/paladin.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(ProviderScope(
      observers: [ProviderLogger()],
      child: const PaladinApp()));
}

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
