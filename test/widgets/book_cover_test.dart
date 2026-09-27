import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/providers/book_details.dart';
import 'package:paladin/widgets/books/book_cover.dart';

import '../helpers/test_database.dart';

const _newBadge = 'assets/new.png';

Finder _unreadBadge() => find.byWidgetPredicate(
    (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == _newBadge);

/// BookCover has no loading spinner (it shows an empty Text while its
/// providers resolve), so this pumps with real wall-clock delays — the same
/// reason `widget_test.dart` can't use `pumpAndSettle` against this app's
/// isolate-backed database — until either finder condition becomes true.
Future<void> _pumpUntil(WidgetTester tester, bool Function() done) async {
  for (int i = 0; i < 30; i++) {
    if (done()) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await tester.pump();
  }
}

void main() {
  const book = Book(
    uuid: 'uuid-1',
    authors: [Author(name: 'Butcher, Jim')],
    description: '',
    lastModified: 0,
    rating: 0,
    readStatus: false,
    tags: [],
    title: 'Brief Cases',
  );

  testWidgets('shows the unread badge for an unread book and hides it once marked read', (tester) async {
    late TestDatabase testDb;

    await tester.runAsync(() async {
      testDb = await TestDatabase.open();
      await testDb.db.insertBook(book);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: testDb.container,
        child: const MaterialApp(home: BookCover(bookUuid: 'uuid-1')),
      ));
      await _pumpUntil(tester, () => _unreadBadge().evaluate().isNotEmpty);

      expect(_unreadBadge(), findsOneWidget);

      // Mark the book read directly against the database, then force
      // bookDetailsProvider to re-read it, the same way a restart would (or,
      // since the earlier fix, the way updateLastReadDate() now does too).
      await testDb.db.updateTable(table: 'books', values: {'readStatus': 1}, where: 'uuid = ?', whereArgs: ['uuid-1']);
      testDb.container.invalidate(bookDetailsProvider('uuid-1'));
      await _pumpUntil(tester, () => _unreadBadge().evaluate().isEmpty);

      expect(_unreadBadge(), findsNothing);
    });

    addTearDown(testDb.dispose);
  });
}
