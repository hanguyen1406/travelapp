abstract class BaseApiServices {
  Future<dynamic> getGetApiResponse(String url);
  Future<dynamic> getPostApiResponse(String url, dynamic data);
  Future<dynamic> getGetApiResponseWithToken(String url, String token);
  Future<dynamic> getPostApiResponseWithToken(
    String url,
    dynamic data,
    String token,
  );
  Future<dynamic> getPutApiResponse(String url, dynamic data);
  Future<dynamic> getPutApiResponseWithToken(
    String url,
    dynamic data,
    String token,
  );
  Future<dynamic> getDeleteApiResponse(String url);
  Future<dynamic> getDeleteApiResponseWithToken(String url, String token);
}
