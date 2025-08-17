import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/calibre_network_service.dart';
import '../services/calibre.dart';

part 'calibre_dio.g.dart';

@Riverpod(keepAlive: true)
class CalibreDio extends _$CalibreDio {
  @override
  Calibre build() {
    String baseUrl = ref.watch(calibreNetworkServiceProvider);
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 900),
      contentType: 'application/json',);

    // allow self-signed certificate
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    return Calibre(dio, baseUrl: baseUrl);
  }
}