import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http_status_code/http_status_code.dart';

import '../database/library_db.dart';
import '../models/book.dart';
import '../models/calibre_book_count.dart';
import '../models/calibre_server.dart';
import '../models/calibre_sync_data.dart';
import '../models/uuid.dart';
import '../providers/book_details.dart';
import '../repositories/books_repository.dart';
import '../repositories/calibre_server_repository.dart';
import '../services/calibre.dart';
import 'cached_cover.dart';
import 'calibre_book_provider.dart';
import 'calibre_dio.dart';
import 'calibre_network_service.dart';
import 'status_provider.dart';

part 'calibre_ws.g.dart';

@Riverpod(keepAlive: true)
class CalibreWS extends _$CalibreWS {
  late LibraryDB _library;
  late Calibre _calibre;
  late Status _status;

  @override
  CalibreSyncData build() {
    var calibreServerAsync = ref.watch(calibreServerRepositoryProvider);
    var networkService = ref.watch(calibreNetworkServiceProvider);

    CalibreServer? server = calibreServerAsync.value;
    String calibreUrl = "";
    if (server != null) {
      calibreUrl = server.calibreServer.isNotEmpty ? server.calibreServer : networkService;
    }

    return CalibreSyncData(calibreServer: calibreUrl);
  }

  Future<void> getBookByUuid(String uuid) async {
    Book book = await ref.read(calibreDioProvider(state.calibreServer)).getBookDetails(uuid);
    await ref.read(bookDetailsProvider(book.uuid).notifier).updateBook(book);
  }

  Future<void> getBooks(List<Book> books) async {
    _status = ref.read(statusProvider.notifier);
    _library = ref.read(libraryDBProvider.notifier);
    _calibre = ref.read(calibreDioProvider(state.calibreServer));

    _status.addStatus('Attempting to download ${books.length} from the server.');

    int index = 0;
    for (var book in books) {
      await _getBook(book);
      updateState(progress: index++ / books.length);
    }
  }

  Future<void> synchroniseWithCalibre() async {
    _status = ref.read(statusProvider.notifier);
    _library = ref.read(libraryDBProvider.notifier);
    _calibre = ref.read(calibreDioProvider(state.calibreServer));

    updateState(syncState: CalibreSyncState.PROCESSING);
    _status.addStatus('Initialising Sync...');

    if (state.syncReadStatuses) {
      await _updateReadStatuses();
    }

    await _getUpdatedBooks();
    await _deleteBooksRemovedFromCalibre();

    _status.addStatus('Completed Synchronisation; please review errors (if any)');
    updateState(syncState: CalibreSyncState.REVIEW,);
  }

  void updateState({String? calibreServer, bool? syncFromEpoch, bool? syncReadStatuses, int? syncDate, double? progress, CalibreSyncState? syncState}) {
    state = state.copyWith(
      calibreServer: calibreServer,
      syncFromEpoch: syncFromEpoch,
      syncReadStatuses: syncReadStatuses,
      progress: progress,
      syncState: syncState,
    );
  }

  Future<void> _deleteBooksRemovedFromCalibre() async {
    List<Uuid> booksInCalibreLibrary = await _calibre.getLibrary();
    LibraryDB library = ref.read(libraryDBProvider.notifier);
    library.uploadTemporaryUuids(booksInCalibreLibrary);
    
    // Look for books in the local library which are not in the calibre library and delete them
    _status.addStatus('Looking for books removed from Calibre...');
    List<Uuid> localBooksInDb = await library.findLocalBooksNotInCalibre();
    if (localBooksInDb.isNotEmpty) {
      _status.addStatus('removing ${localBooksInDb.length} books from the local database');
      for (Uuid uuid in localBooksInDb) {
        library.removeBook(uuid);
      }
    } else {
      _status.addStatus('No books removed from Calibre. Phew.');
    }

    // Then look for books in the calibre library which are not in the local library and download them
    _status.addStatus('Looking for missing books...');
    List<Uuid> remoteBooksNotInDb = await library.findRemoteBooksNotInDb();
    if (remoteBooksNotInDb.isNotEmpty) {
      _status.addStatus('Downloading ${remoteBooksNotInDb.length} books we missed previously!');
      int index = 0;
      for (Uuid uuid in remoteBooksNotInDb) {
        await _getBook(await _calibre.getBookDetails(uuid.uuid));
        updateState(progress: index++ / remoteBooksNotInDb.length);
      }
    } else {
      _status.addStatus('No missing books. (as expected!)');
    }
  }

  Future<void> _downloadBook(Book book) async {
    final file = File(await book.path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    final response = ref.read(calibreDioProvider(state.calibreServer)).getBook(book.uuid, 4096);
    final sink = file.openWrite();
    await for (final chunk in response) {
      sink.add(chunk);
    }
    await sink.flush();
    await sink.close();

    ref.read(cachedCoverProvider(book)); // As a side effect, this will cache the cover for us.
  }

  Future<void> _getBook(Book book) async {
    ref.read(calibreBookProvider(BooksType.processed).notifier).add(book);
    try {
      // Only download the Book if something has changed since last time!
      if (book.lastModified > await ref.read(libraryDBProvider.notifier).getLastModified(book)) {
        await _downloadBook(book);
        await _library.insertBook(book);
      } else {
        _status.addStatus("${book.title} hasn't changed; not downloading!");
      }
    } catch (e) {
      ref.read(calibreBookProvider(BooksType.error).notifier).add(book);
      String exception = 'Got exception processing "${book.title}":';
      if (e is DioException) {
        if (e.response != null) {
          if (e.response!.statusCode != null) {
            exception = '$exception ${getStatusMessage(e.response!.statusCode!)}';
          } else {
            exception = '$exception $e';
          }
          _status.addStatus(exception);
        }
      }
    }
  }

  Future<void> _getUpdatedBooks() async {
    int lastConnected = state.syncFromEpoch ? 0 : ref.read(calibreServerRepositoryProvider).value!.lastConnected;

    const int size = 100;
    CalibreBookCount bookCount = await _calibre.getCount(lastConnected, 1);
    _status.addStatus('Received ${bookCount.count} Books in the batch.');

    int offset = 0;
    while (offset < bookCount.count) {
      await _getBooksWithOffset(lastConnected, offset, size, bookCount.count);
      offset += size;
    }
  }

  Future<void> _getBooksWithOffset(int lastConnected, int offset, int size, int total) async {
    _status.addStatus('Syncing ${(offset + size) > total ? total - offset : size} books ($offset/$total)');
    ref.read(calibreBookProvider(BooksType.processed).notifier).clear();

    List<Book> books = await _calibre.getBooks(lastConnected, offset, size);
    int index = offset;
    for (Book book in books) {
      await _getBook(book);
      updateState(progress: index++ / total);
    }
  }

  Future<void> _updateReadStatuses() async {
    int lastConnected = ref.read(calibreServerRepositoryProvider).value!.lastConnected;

    _status.addStatus('Updating Last Read statuses.');

    List<Book> books = await ref.read(booksRepositoryProvider.notifier).getReadingList(lastConnected);
    _calibre.updateBooks(books);

    _status.addStatus('Updated Last Read statuses.');
  }
}