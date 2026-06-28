import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_versions.dart';
import '../models/course_option_model.dart';

class LocalCourseOptionDataSource {
  LocalCourseOptionDataSource({required this.preferences, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final SharedPreferences preferences;
  final http.Client _httpClient;

  static const String _storageKey = 'course_options_json_v2';
  static const String _seedHashKey = 'course_options_seed_hash_v2';
  static const String _assetSeedPath = 'assets/data/professors_seed.json';

  Future<List<CourseOptionModel>> getAll() async {
    final storedJson = preferences.getString(_storageKey);
    final storedSeedHash = preferences.getString(_seedHashKey);

    final seedJson = await _loadSeedJson(fallbackJson: storedJson);
    final seedHash = _stableHash(seedJson);

    if (storedJson == null || storedSeedHash != seedHash) {
      await _persist(seedJson, seedHash);
      return _decode(seedJson);
    }

    return _decode(storedJson);
  }

  Future<List<CourseOptionModel>> reloadFromPublishedSeed() async {
    final seedJson = await _loadSeedJson();
    final seedHash = _stableHash(seedJson);
    await _persist(seedJson, seedHash);
    return _decode(seedJson);
  }

  Future<void> saveAll(List<CourseOptionModel> options) async {
    final encoded = jsonEncode(options.map((option) => option.toJson()).toList());
    await preferences.setString(_storageKey, encoded);
  }

  Future<void> _persist(String jsonSource, String seedHash) async {
    await preferences.setString(_storageKey, jsonSource);
    await preferences.setString(_seedHashKey, seedHash);
  }

  Future<String> _loadSeedJson({String? fallbackJson}) async {
    if (kIsWeb) {
      try {
        final uri = Uri.base.resolve(
          '${AppVersions.seedFilePath}?v=${Uri.encodeQueryComponent(AppVersions.seedDataVersion)}&t=${DateTime.now().millisecondsSinceEpoch}',
        );

        final response = await _httpClient.get(
          uri,
          headers: const {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
          },
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response.body;
        }
      } catch (_) {
        // Si no hay red o el archivo público no está disponible, se usa fallback.
      }
    }

    if (fallbackJson != null && fallbackJson.trim().isNotEmpty) {
      return fallbackJson;
    }

    return rootBundle.loadString(_assetSeedPath);
  }

  List<CourseOptionModel> _decode(String source) {
    final decoded = jsonDecode(source);
    final List<dynamic> items;

    if (decoded is List<dynamic>) {
      items = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final value = decoded['items'] ?? decoded['options'] ?? decoded['courses'];
      if (value is! List<dynamic>) {
        throw const FormatException(
          'El JSON debe ser una lista o un objeto con items/options/courses.',
        );
      }
      items = value;
    } else {
      throw const FormatException('El JSON no tiene un formato válido.');
    }

    return items
        .map((item) => CourseOptionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String _stableHash(String input) {
    var hash = 5381;
    for (final codeUnit in input.codeUnits) {
      hash = ((hash << 5) + hash) ^ codeUnit;
    }
    return hash.toUnsigned(32).toString();
  }
}
