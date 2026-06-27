import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_option_model.dart';

class LocalCourseOptionDataSource {
  LocalCourseOptionDataSource({required this.preferences});

  final SharedPreferences preferences;

  static const String _storageKey = 'course_options_json';
  static const String _seedPath = 'assets/data/professors_seed.json';

  Future<List<CourseOptionModel>> getAll() async {
    final storedJson = preferences.getString(_storageKey);

    if (storedJson == null) {
      final seedJson = await rootBundle.loadString(_seedPath);
      await preferences.setString(_storageKey, seedJson);
      return _decode(seedJson);
    }

    return _decode(storedJson);
  }

  Future<void> saveAll(List<CourseOptionModel> options) async {
    final encoded = jsonEncode(options.map((option) => option.toJson()).toList());
    await preferences.setString(_storageKey, encoded);
  }

  List<CourseOptionModel> _decode(String source) {
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => CourseOptionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
