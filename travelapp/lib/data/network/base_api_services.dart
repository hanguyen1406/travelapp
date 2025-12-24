abstract class BaseApiServices {
  Future<dynamic> getApi(String url);

  Future<dynamic> postApi(String url, dynamic data);

  Future<dynamic> postApiWithToken(String url, dynamic data, String token);

  Future<dynamic> getApiWithToken(String url, String token);
}
