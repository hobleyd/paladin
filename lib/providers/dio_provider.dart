import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/calibre.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Calibre dioProvider() {
  final dio = Dio();
  dio.options = BaseOptions(
    baseUrl: "https://calibrews.sharpblue.com.au/",
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 900),
    contentType: 'application/json',);
  return Calibre(dio);
}