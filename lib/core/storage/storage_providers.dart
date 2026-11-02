import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'offline_cache_service.dart';

final offlineCacheServiceProvider = Provider<IOfflineCacheService>((ref) {
  return OfflineCacheService();
});
