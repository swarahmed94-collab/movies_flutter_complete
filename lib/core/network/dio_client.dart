import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Firebase ID tokens must NEVER be sent to the public movie API by default.
/// Enable injection only when the server contract explicitly requires it.
class DioClient {
  DioClient({
    Dio? dio,
    Future<String?> Function()? tokenProvider,
    bool Function(RequestOptions request)? attachToken,
  }) : _dio = dio ?? Dio(BaseOptions(
         baseUrl: AppConfig.apiBaseUrl,
         connectTimeout: const Duration(seconds: 15),
         receiveTimeout: const Duration(seconds: 20),
         sendTimeout: const Duration(seconds: 20),
         responseType: ResponseType.json,
         headers: {'Accept': 'application/json'},
       )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final authorized = attachToken?.call(options) ?? false;
          if (authorized && tokenProvider != null) {
            try {
              final token = await tokenProvider();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (error) {
              handler.reject(DioException(
                requestOptions: options,
                error: error,
                type: DioExceptionType.unknown,
              ));
              return;
            }
          }
          handler.next(options);
        },
        onError: (error, handler) => handler.next(error),
      ),
    );
  }

  final Dio _dio;
  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
}
