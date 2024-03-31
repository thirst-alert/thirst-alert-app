import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'identity_manager.dart';

final unauthenticatedRoutes = ['/auth/register', '/auth/login', '/auth/refresh', '/auth/verify'
];

final identityManager = IdentityManager();

Dio dio = Dio(BaseOptions(
  baseUrl: dotenv.env['BASE_URL'] as String,
))
..interceptors.add(InterceptorsWrapper(
  // ADD ACCESS TOKEN TO REQUEST
  onRequest: (options, handler) async {
    if (unauthenticatedRoutes.contains(options.path)) return handler.next(options);
    if (identityManager.accessToken != null) {
      options.headers['Authorization'] = 'Bearer ${identityManager.accessToken}';
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
        if (identityManager.refreshToken != null) {
          final newAccessToken = await _getNewAccessToken();
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
));
// ..interceptors.add(PrettyDioLogger());

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

Future<String> _getNewAccessToken() async {
  final response = await _standardizeResponse(dio.post('/auth/refresh', data: {
    'refreshToken': identityManager.refreshToken,
    'username': identityManager.username
  }));
  if (response.success) {
    identityManager.accessToken = response.data['token'];
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
      identityManager.accessToken = response.data['token'];
      identityManager.refreshToken = response.data['refreshToken'];
      identityManager.username = response.data['user']['username'];
      identityManager.userId = response.data['user']['id'];
      identityManager.email = response.data['user']['email'];
    }
    return response;
  }

  Future<ApiResponse<dynamic>> register(Map<String, dynamic> body) async {
    return await _standardizeResponse(dio.post('/auth/register', data: body));
  }

  Future<ApiResponse<dynamic>> verify(Map<String, dynamic> body) async {
    return await _standardizeResponse(dio.post('/auth/verify', data: body));
  }

  Future<ApiResponse<dynamic>> resetPassword(Map<String, dynamic> body) async {
    return await _standardizeResponse(dio.post('/user/reset-password', data: body));
  }
  
  Future<ApiResponse<dynamic>> changePassword(Map<String, dynamic> body) async {
    return await _standardizeResponse(dio.patch('/user/patch-password', data: body));
  }

  Future<ApiResponse<dynamic>> deleteUser() async {
    return await _standardizeResponse(dio.delete('/user'));
  }

  Future<ApiResponse<dynamic>> createSensor(Map<String, dynamic> body) async {
    return await _standardizeResponse(dio.post('/sensor', data: body));
  }

  Future<ApiResponse<dynamic>> deleteSensor(String sensorId) async {
    return await _standardizeResponse(dio.delete('/sensor/$sensorId'));
  }

  Future<ApiResponse<dynamic>> getSensors() async {
    return await _standardizeResponse(dio.get('/sensor'));
  }
  
  Future<ApiResponse<dynamic>> viewSensor(String sensorId) async {
    return await _standardizeResponse(dio.get('/sensor/$sensorId'));
  }

  Future<ApiResponse<dynamic>> patchSensor(String sensorId, Map<String, dynamic> body) async {
    return await _standardizeResponse(dio.patch('/sensor/$sensorId', data: body));
  }

  Future<bool> downloadSensorImage(String userId, String sensorId) async {
    final ApiResponse<dynamic> response = await _standardizeResponse(dio.get('/gcs/sensor/$sensorId'));
    if (!response.success) return false;
    try {
      final String url = response.data['url'];
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final File file = File('${appDocumentsDir.path}/$userId-$sensorId');
      final Dio gcsDio = Dio();
      await gcsDio.download(url, file.path);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadSensorImage(String userId, String sensorId) async {
    final ApiResponse<dynamic> response = await _standardizeResponse(dio.put('/gcs/sensor/$sensorId'));
    if (!response.success) return false;
    try {
      final String url = response.data['url'];
      final File image = File('${(await getApplicationDocumentsDirectory()).path}/$userId-$sensorId');
      final FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: '$userId-$sensorId'),
      });
      await dio.put(url, data: formData);
      return true;
    } catch (e) {
      return false;
    }

  Future<ApiResponse<dynamic>> getMeasurements(String sensorId) async {
    return await _standardizeResponse(dio.get('/measurement/$sensorId', queryParameters: {
      //'limit': 31,
      'offset': 12,
      'sort': -1,
      //'startDate': '2024-02-18T17:35:17.206+00:00',
    }));
  }
}