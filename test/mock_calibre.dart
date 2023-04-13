import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:paladin/services/calibre.dart';

import 'mock_calibre.mocks.dart';
import 'testdata.dart';

@GenerateMocks([Dio])
void main() {
  group('Calibre', () {
    final mockDio = MockDio();

    when(mockDio.options).thenAnswer((_) =>
        BaseOptions(
          baseUrl: "https://calibrews.sharpblue.com.au/",
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 900),
          contentType: 'application/json',));

    RequestOptions requestOptions = RequestOptions({'method': 'GET'});
    when(mockDio.fetch()).thenAnswer((_) async =>
        Response(data: booksResponseData, requestOptions: RequestOptions(path: 'https://calibrews.sharpblue.com.au/calibre/books/0')));

    final mockCalibre = Calibre(mockDio);

    test('test getBooks', () async {
      List<Book> books = await mockCalibre.getBooks(1672577852);
      expect(books.length, equals(1));
      expect(books[0].Title, equals('A Book'));
    });
  });
}
