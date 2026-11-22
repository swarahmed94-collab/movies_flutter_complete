import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../error/failure_mapper.dart';
import '../error/failures.dart';
import '../storage/hive_service.dart';
import 'dio_client.dart';

/// Reusable cache-first / stale-on-error behavior for documented GET endpoints.
/// No endpoint paths or JSON field names are assumed here.
class CachedJsonRequest {
  const CachedJsonRequest(this._client, this._cache);
  final DioClient _client;
  final HiveService _cache;

  Future<Either<Failure, Map<String, dynamic>>> get({
    required String path,
    required String cacheKey,
    Map<String, dynamic>? queryParameters,
    Duration maxAge = const Duration(hours: 6),
    bool cacheFirst = true,
    CancelToken? cancelToken,
  }) async {
    if (cacheFirst) {
      try {
        final fresh = _cache.getJson(cacheKey, maxAge: maxAge);
        if (fresh != null) return right(fresh);
      } catch (_) {
        // A cache read error should not prevent the API call.
      }
    }

    try {
      final response = await _client.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      final data = response.data;
      if (data == null) {
        return left(const ApiFailure('The server returned no JSON document.'));
      }
      try {
        await _cache.putJson(cacheKey, data);
      } catch (_) {
        // Network data is still usable even if the local disk is unavailable.
      }
      return right(data);
    } catch (error) {
      // A deliberate cancellation should not silently return stale content.
      if (error is DioException &&
          error.type == DioExceptionType.cancel) {
        return left(const NetworkFailure('Request was cancelled.'));
      }
      try {
        final stale = _cache.getJson(cacheKey, allowStale: true);
        if (stale != null) return right(stale);
      } catch (_) {
        // Preserve the original network failure as the useful result.
      }
      return left(FailureMapper.from(error));
    }
  }
}
