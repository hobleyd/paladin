import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../models/json_book.dart';
import '../models/tag.dart';

part 'calibre.g.dart';

@RestApi(baseUrl: 'https://calibrews.sharpblue.com.au/')
abstract class Calibre {
  factory Calibre(Dio dio, {String baseUrl}) = _Calibre;

  @GET("/calibre/book/{uuid}")
  @DioResponseType(ResponseType.bytes)
  Stream<List<int>> getBook(@Path("uuid") String uuid, @Query('chunk_size') int chunkSize);

  @GET("/calibre/books/{last_modified}")
  Future<List<JSONBook>> getBooks(@Path("last_modified") int last_modified, @Query('page') int page, @Query('size') int size);

  @GET("/calibre/count")
  Future<int> getCount(@Query('last_modified') int last_modified);

  @GET("/calibre/tags/{uuid}")
  Future<List<Tag>> getTags(@Path("uuid") String uuid);

  @PUT("/calibre/update")
  @Headers(<String, dynamic>{
    "Content-Type" : "application/json",
  })
  Future<List<JSONBook>> updateBooks(@Body() List<JSONBook> books);
}