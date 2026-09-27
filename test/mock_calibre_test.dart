import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/services/calibre.dart';

import 'mock_calibre_test.mocks.dart';
import 'testdata.dart';

@GenerateMocks([Dio])
void main() {
  group('Calibre', () {
    final mockDio = MockDio();

    when(mockDio.options).thenAnswer((_) => BaseOptions(
          baseUrl: "https://calibrews.sharpblue.com.au/",
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 900),
          contentType: 'application/json',
        ));

    // RequestOptions has no value equality, so matching an exact instance
    // (as the original version of this test tried to) never matches what
    // Calibre.getBooks actually constructs; stub the call generically. The
    // generated client casts the response to Response<List<dynamic>>, so
    // `data` has to already be decoded, not the raw JSON string.
    when(mockDio.fetch<List<dynamic>>(any)).thenAnswer((_) async => Response<List<dynamic>>(
          data: jsonDecode(booksResponseData) as List<dynamic>,
          requestOptions: RequestOptions(path: 'https://calibrews.sharpblue.com.au/calibre/books/0'),
        ));

    final mockCalibre = Calibre(mockDio);

    test('getBooks parses the response into Book models', () async {
      List<Book> books = await mockCalibre.getBooks(1672577852, 0, 10);

      expect(books, hasLength(2));

      expect(books[0].title, equals('Brief Cases'));
      expect(books[0].uuid, equals('fb46a7d7-e4f5-4daa-94ce-0891e4463b82'));
      expect(books[0].readStatus, isFalse);
      expect(books[0].authors.map((a) => a.name), ['Butcher, Jim']);
      expect(books[0].series?.series, 'Dresden Files, The');
      expect(books[0].tags.map((t) => t.tag), ['Mystery & Detective', 'Supernatural', 'Magic']);

      expect(books[1].title, equals('Ghost Fleet: A Novel of the Next World War'));
      expect(books[1].authors.map((a) => a.name), ['Singer, P. W.', 'Cole, August']);
      expect(books[1].series, isNull);
    });
  });
}
