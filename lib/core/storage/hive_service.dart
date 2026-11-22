import 'package:hive_flutter/hive_flutter.dart';

/// Stores JSON-compatible API responses. Feature-specific adapters and
/// cache keys are added only after the actual API schema is verified.
class HiveService {
  HiveService._(this._cache);
  final Box<Map> _cache;
  static const _cacheBoxName = 'movie_api_cache';

  static Future<HiveService> initialize() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<Map>(_cacheBoxName);
    return HiveService._(box);
  }

  Future<void> putJson(String key, Map<String, dynamic> json) =>
      _cache.put(key, <String, Object?>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'payload': json,
      });

  /// Returns null if absent, expired, or incompatible.
  /// Set allowStale=true when implementing fallback-to-cache after network errors.
  Map<String, dynamic>? getJson(
    String key, {
    Duration maxAge = const Duration(hours: 6),
    bool allowStale = false,
  }) {
    final record = _cache.get(key);
    if (record == null) return null;
    final timestamp = record['timestamp'];
    final payload = record['payload'];
    if (timestamp is! int || payload is! Map) return null;
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
    if (!allowStale && age > maxAge) return null;
    return Map<String, dynamic>.from(payload);
  }

  Future<void> remove(String key) => _cache.delete(key);
  Future<void> clear() async {
    await _cache.clear();
  }
  Future<void> close() => _cache.close();
}
