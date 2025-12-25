abstract class BaseApiServices {
  Future<dynamic> getGetApiResponse(String url);
  Future<dynamic> getPostApiResponse(String url, dynamic data);
  Future<dynamic> getGetApiResponseWithToken(String url, String token);
  Future<dynamic> getPostApiResponseWithToken(String url, dynamic data, String token);
}

