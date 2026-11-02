import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IOfflineCacheService {
  Future<void> cacheJsonList(String key, List<Map<String, dynamic>> data);
  Future<List<Map<String, dynamic>>?> getCachedJsonList(String key);
  Future<void> cacheJsonObject(String key, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedJsonObject(String key);
  Future<void> clearCache(String key);
  Future<void> clearAll();
}

class OfflineCacheService implements IOfflineCacheService {
  final SharedPreferences? prefs;

  OfflineCacheService({this.prefs});

  Future<SharedPreferences> get _instance async => prefs ?? await SharedPreferences.getInstance();

  @override
  Future<void> cacheJsonList(String key, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await _instance;
      final jsonString = jsonEncode(data);
      await prefs.setString(key, jsonString);
    } catch (_) {}
  }

  @override
  Future<List<Map<String, dynamic>>?> getCachedJsonList(String key) async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheJsonObject(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await _instance;
      final jsonString = jsonEncode(data);
      await prefs.setString(key, jsonString);
    } catch (_) {}
  }

  @override
  Future<Map<String, dynamic>?> getCachedJsonObject(String key) async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      final prefs = await _instance;
      await prefs.remove(key);
    } catch (_) {}
  }

  @override
  Future<void> clearAll() async {
    try {
      final prefs = await _instance;
      await prefs.clear();
    } catch (_) {}
  }
}
