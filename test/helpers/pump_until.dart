import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the widget tree with real wall-clock delays between frames, until
/// no [CircularProgressIndicator] remains (or [maxPumps] is reached).
///
/// Must be called from inside `tester.runAsync`. This app's database
/// (sqflite_common_ffi's isolate-backed `databaseFactoryFfi`) does genuine
/// cross-isolate I/O for every query, and `pumpAndSettle` can't drive that:
/// it never inserts a real wall-clock gap between pumps, so the worker
/// isolate never gets a chance to reply, and an indeterminate
/// [CircularProgressIndicator] keeps scheduling frames indefinitely anyway
/// (`pumpAndSettle` has no way to tell that apart from "still loading").
Future<void> pumpUntilSettled(
  WidgetTester tester, {
  int maxPumps = 30,
  Duration step = const Duration(milliseconds: 200),
}) async {
  for (int i = 0; i < maxPumps; i++) {
    await Future<void>.delayed(step);
    await tester.pump();
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
}
