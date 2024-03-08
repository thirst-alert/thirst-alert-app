import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final unauthenticatedRoutes = ['/auth/register', '/auth/login', '/auth/refresh', '/auth/verify'
];
const storage = FlutterSecureStorage();

Dio dio = Dio(BaseOptions(
  baseUrl: dotenv.env['BASE_URL'] as String,
))
..interceptors.add(InterceptorsWrapper(
  // ADD ACCESS TOKEN TO REQUEST
  onRequest: (options, handler) async {
    if (unauthenticatedRoutes.contains(options.path)) return handler.next(options);
    if (await storage.containsKey(key: 'access_token')) {
      final accessToken = await storage.read(key: 'access_token');
      options.headers['Authorization'] = 'Bearer $accessToken';
      handler.next(options);
    } else {
      // REDIRECT TO LOGIN SCREEN
    }
  },
  onError: (DioException error, handler) async {
    final request = error.requestOptions;
    if (unauthenticatedRoutes.contains(request.path)) return handler.next(error);

    if (error.response?.statusCode == 401) {
      try {
        final refreshToken = await storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          final newAccessToken = await _getNewAccessToken(refreshToken);
          request.headers['Authorization'] = 'Bearer $newAccessToken';
          return handler.resolve(await _retry(request));
        } else {
          // SHOULD NEVER GET HERE, BUT REDIRECT TO LOGIN SCREEN
        }
      } catch (e) {
        throw Exception('Failed to refresh access token');
      }
    }
  }
))
..interceptors.add(PrettyDioLogger());

class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.error,
  });

  // debug
  @override
  String toString() {
    return 'ApiResponse { success: $success, statusCode: $statusCode, data: $data, error: $error }';
  }
}

Future<ApiResponse<T>> _standardizeResponse<T>(Future<Response<T>> responseFuture) async {
  try {
    final Response<T> response = await responseFuture;
    return ApiResponse<T>(
      success: true,
      statusCode: response.statusCode ?? 200,
      data: response.data,
    );
  } catch (e) {
    if (e is DioException) {
      final dioError = e;
      return ApiResponse<T>(
        success: false,
        statusCode: dioError.response?.statusCode ?? -1,
        error: dioError.response?.data['error']['message'] as String? ?? 'Unknown error',
      );
    } else {
      return ApiResponse<T>(
        success: false,
        statusCode: -1,
        error: e.toString(),
      );
    }
  }
}

Future<String> _getNewAccessToken(String refreshToken) async {
  final username = await storage.read(key: 'username');
  final response = await _standardizeResponse(dio.post('/auth/refresh', data: {
    'refreshToken': refreshToken,
    'username': username
  }));
  if (response.success) {
    await storage.write(key: 'access_token', value: response.data['token']);
    return response.data['token'];
  } else {
    throw Exception('Failed to refresh access token');
  }
}

Future<Response> _retry(RequestOptions request) async {
  final options = Options(
    method: request.method,
    headers: request.headers,
  );
  final response =  await dio.request(
    request.path,
    data: request.data,
    queryParameters: request.queryParameters,
    options: options,
  );
  return Future.value(response);
}

class Api {
  Future<ApiResponse<dynamic>> login(Map<String, dynamic> body) async {
    final response = await _standardizeResponse(dio.post('/auth/login', data: body));
    if (response.success) {
      await storage.write(key: 'access_token', value: response.data['token']);
      await storage.write(key: 'refresh_token', value: response.data['refreshToken']);
      await storage.write(key: 'username', value: response.data['user']['username']);
    }
    return response;
  }

  Future<ApiResponse<dynamic>> register(Map<String, dynamic> body) async {
    return await _standardizeResponse(dio.post('/auth/register', data: body));
  }
  

  Future<ApiResponse<dynamic>> verify(Map<String, dynamic> body) async {
    return await _standardizeResponse(dio.post('/auth/verify', data: body));
  }

  Future<ApiResponse<dynamic>> deleteUser() async {
    return await _standardizeResponse(dio.delete('/user'));
  }

  Future<ApiResponse<dynamic>> test() async {
    return await _standardizeResponse(dio.post('/test'));
  }
}