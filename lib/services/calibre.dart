import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../models/calibre_book_count.dart';
import '../models/calibre_health.dart';
import '../models/calibre_update_response.dart';
import '../models/json_book.dart';
import '../models/tag.dart';

part 'calibre.g.dart';

@RestApi()
abstract class Calibre {
  factory Calibre(Dio dio, {String baseUrl}) = _Calibre;

  @GET("/book/{uuid}")
  @DioResponseType(ResponseType.bytes)
  Stream<List<int>> getBook(@Path("uuid") String uuid, @Query('chunk_size') int chunkSize);

  @GET("/books")
  Future<List<JSONBook>> getBooks(@Query("last_modified") int last_modified, @Query('offset') int offset, @Query('limit') int limit);
  
  @GET("/count/{last_modified}/{limit}")
  Future<CalibreBookCount> getCount(@Path('last_modified') int last_modified, @Path('limit') int limit);

  @GET("/health")
  Future<CalibreHealth> getHealth();

  @GET("/tags/{uuid}")
  Future<List<Tag>> getTags(@Path("uuid") String uuid);

  @PUT("/update")
  @Headers(<String, dynamic>{
    "Content-Type" : "application/json",
  })
  Future<CalibreUpdateResponse> updateBooks(@Body() List<JSONBook> books);
}