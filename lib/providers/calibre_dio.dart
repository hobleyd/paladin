import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/calibre.dart';

part 'calibre_dio.g.dart';

@Riverpod(keepAlive: true)
class CalibreDio extends _$CalibreDio {
  @override
  Calibre build() {
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: "https://calibrews.sharpblue.com.au/",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 900),
      contentType: 'application/json',);
    return Calibre(dio);
  }
}