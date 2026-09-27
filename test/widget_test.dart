// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:paladin/paladin_app.dart';
import 'package:paladin/widgets/menu/menu_buttons.dart';

import 'helpers/fake_path_provider.dart';
import 'helpers/pump_until.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('paladin_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('Paladin boots to an empty home screen', (WidgetTester tester) async {
    // sqflite_common_ffi (databaseFactoryFfi) dispatches every query to a
    // background isolate, so `pumpAndSettle` can't be used here: it never
    // inserts a real wall-clock gap between pumps, so it never gives that
    // isolate a chance to reply, and it spins forever regardless (an
    // indeterminate CircularProgressIndicator also always keeps scheduling
    // frames, which pumpAndSettle can't distinguish from "still loading").
    // `runAsync` + a bounded real-delay pump loop is the pattern that
    // actually lets database-backed providers resolve under test.
    await tester.runAsync(() async {
      await tester.pumpWidget(const ProviderScope(child: PaladinApp()));
      await pumpUntilSettled(tester);
    });

    // The database opened and the home screen rendered instead of the
    // loading spinner or the fatal-error fallback.
    expect(find.byType(MenuButtons), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text("It's time to panic; we can't open the database!"), findsNothing);
  });
}
