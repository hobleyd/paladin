import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/models/calibre_book_count.dart';
import 'package:paladin/models/calibre_sync_data.dart';
import 'package:paladin/models/calibre_update_response.dart';
import 'package:paladin/models/uuid.dart';
import 'package:paladin/providers/calibre_dio.dart';
import 'package:paladin/providers/calibre_ws.dart';
import 'package:paladin/repositories/books_repository.dart';
import 'package:paladin/repositories/calibre_server_repository.dart';
import 'package:paladin/services/calibre.dart';

import '../helpers/keep_alive.dart';
import '../helpers/test_database.dart';
import 'calibre_ws_test.mocks.dart';

const _testServer = 'https://calibre.test';

Book _book(String uuid, {int lastModified = 100, int? lastRead}) => Book(
      uuid: uuid,
      authors: const [Author(name: 'Butcher, Jim')],
      description: '',
      lastModified: lastModified,
      lastRead: lastRead,
      rating: 0,
      readStatus: false,
      tags: const [],
      title: 'Title $uuid',
    );

@GenerateMocks([Calibre])
void main() {
  late TestDatabase testDb;
  late MockCalibre mockCalibre;

  setUp(() async {
    mockCalibre = MockCalibre();
    when(mockCalibre.getBook(any, any)).thenAnswer((_) => const Stream<List<int>>.empty());
    when(mockCalibre.updateBooks(any)).thenAnswer((_) async => CalibreUpdateResponse(status: 'ok', message: ''));

    testDb = await TestDatabase.open(overrides: [
      calibreDioProvider(_testServer).overrideWithValue(mockCalibre),
    ]);

    keepAlive(testDb.container, calibreWSProvider);
    // Every DatabaseNotifier repository registers itself with CalibreWS the
    // first time it's built, and synchroniseWithCalibre() notifies all of
    // them when it finishes. Keep this one alive the way a watching widget
    // (MenuButtons) would in the real app, or it gets disposed before then.
    keepAlive(testDb.container, booksRepositoryProvider);
    await testDb.container.read(calibreServerRepositoryProvider.future);
    await testDb.container.read(calibreServerRepositoryProvider.notifier).updateServerDetails(calibreServer: _testServer);
  });

  tearDown(() {
    testDb.dispose();
  });

  // synchroniseWithCalibre() notifies every registered DatabaseNotifier
  // without awaiting the notifications; give that fire-and-forget loop a
  // moment to finish so it doesn't run after the test (and its
  // container-disposing tearDown) has already completed.
  Future<void> sync() async {
    await testDb.container.read(calibreWSProvider.notifier).synchroniseWithCalibre();
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  test('synchroniseWithCalibre downloads new books reported by the server', () async {
    when(mockCalibre.getCount(any, any)).thenAnswer((_) async => CalibreBookCount(count: 1, books: []));
    when(mockCalibre.getBooks(any, any, any)).thenAnswer((_) async => [_book('uuid-1')]);
    when(mockCalibre.getLibrary()).thenAnswer((_) async => [const Uuid(uuid: 'uuid-1')]);

    await sync();

    final rows = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['uuid-1']);
    expect(rows, hasLength(1));
    expect(rows.single['lastModified'], 100);

    expect(testDb.container.read(calibreWSProvider).syncState, CalibreSyncState.REVIEW);
  });

  test('synchroniseWithCalibre does not re-download a book that has not changed', () async {
    await testDb.db.insertBook(_book('uuid-1', lastModified: 100));

    when(mockCalibre.getCount(any, any)).thenAnswer((_) async => CalibreBookCount(count: 1, books: []));
    when(mockCalibre.getBooks(any, any, any)).thenAnswer((_) async => [_book('uuid-1', lastModified: 100)]);
    when(mockCalibre.getLibrary()).thenAnswer((_) async => [const Uuid(uuid: 'uuid-1')]);

    await sync();

    // getBook (the epub download endpoint) should never be hit for an
    // unchanged book.
    verifyNever(mockCalibre.getBook(any, any));
  });

  test('synchroniseWithCalibre re-downloads a book whose lastModified has advanced', () async {
    await testDb.db.insertBook(_book('uuid-1', lastModified: 100));

    when(mockCalibre.getCount(any, any)).thenAnswer((_) async => CalibreBookCount(count: 1, books: []));
    when(mockCalibre.getBooks(any, any, any)).thenAnswer((_) async => [_book('uuid-1', lastModified: 200)]);
    when(mockCalibre.getLibrary()).thenAnswer((_) async => [const Uuid(uuid: 'uuid-1')]);

    await sync();

    verify(mockCalibre.getBook('uuid-1', any)).called(1);
    final rows = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['uuid-1']);
    expect(rows.single['lastModified'], 200);
  });

  test('synchroniseWithCalibre removes local books no longer reported by the server', () async {
    await testDb.db.insertBook(_book('uuid-gone'));

    when(mockCalibre.getCount(any, any)).thenAnswer((_) async => CalibreBookCount(count: 0, books: []));
    when(mockCalibre.getBooks(any, any, any)).thenAnswer((_) async => []);
    when(mockCalibre.getLibrary()).thenAnswer((_) async => []);

    await sync();

    final rows = await testDb.db.query(table: 'books', where: 'uuid = ?', whereArgs: ['uuid-gone']);
    expect(rows, isEmpty);
  });

  test('synchroniseWithCalibre updates last_connected on the calibre server row', () async {
    when(mockCalibre.getCount(any, any)).thenAnswer((_) async => CalibreBookCount(count: 0, books: []));
    when(mockCalibre.getBooks(any, any, any)).thenAnswer((_) async => []);
    when(mockCalibre.getLibrary()).thenAnswer((_) async => []);

    await sync();

    final rows = await testDb.db.query(table: 'calibre_library');
    expect(rows.single['last_connected'], greaterThan(0));
  });

  test('synchroniseWithCalibre pushes local read statuses to the server by default', () async {
    await testDb.db.insertBook(_book('uuid-1', lastRead: 500));

    when(mockCalibre.getCount(any, any)).thenAnswer((_) async => CalibreBookCount(count: 0, books: []));
    when(mockCalibre.getBooks(any, any, any)).thenAnswer((_) async => []);
    when(mockCalibre.getLibrary()).thenAnswer((_) async => [const Uuid(uuid: 'uuid-1')]);

    await sync();

    final captured = verify(mockCalibre.updateBooks(captureAny)).captured.single as List<Book>;
    expect(captured.map((b) => b.uuid), contains('uuid-1'));
  });
}
