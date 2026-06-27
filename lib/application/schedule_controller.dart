import 'package:flutter/material.dart';

import '../domain/entities/class_session.dart';
import '../domain/entities/course_option.dart';
import '../domain/entities/time_range.dart';
import '../domain/entities/week_day.dart';
import '../domain/repositories/course_option_repository.dart';
import 'schedule_combination_service.dart';

class ScheduleController extends ChangeNotifier {
  ScheduleController({
    required this.repository,
    required this.combinationService,
  });

  final CourseOptionRepository repository;
  final ScheduleCombinationService combinationService;

  bool isLoading = false;
  List<CourseOption> options = [];
  Set<String> selectedCandidateIds = {};
  List<List<CourseOption>> validCombinations = [];
  int selectedCombinationIndex = 0;

  List<CourseOption> get selectedCandidates => options
      .where((option) => selectedCandidateIds.contains(option.id))
      .toList();

  List<CourseOption> get activeSchedule {
    if (validCombinations.isNotEmpty &&
        selectedCombinationIndex >= 0 &&
        selectedCombinationIndex < validCombinations.length) {
      return validCombinations[selectedCombinationIndex];
    }
    return selectedCandidates;
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    options = await repository.getAll();
    selectedCandidateIds = options.map((option) => option.id).toSet();
    generateCombinations();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addOption({
    required String subject,
    required String professor,
    required String section,
    required List<WeekDay> days,
    required String start,
    required String end,
  }) async {
    final sessions = days
        .map(
          (day) => ClassSession(
            day: day,
            timeRange: TimeRange(start: start, end: end),
          ),
        )
        .toList();

    final option = CourseOption(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      subject: subject.trim(),
      professor: professor.trim(),
      section: section.trim().isEmpty ? 'Sin sección' : section.trim(),
      sessions: sessions,
    );

    options = [...options, option];
    selectedCandidateIds.add(option.id);
    await repository.saveAll(options);
    generateCombinations();
    notifyListeners();
  }

  Future<void> deleteOption(String id) async {
    options = options.where((option) => option.id != id).toList();
    selectedCandidateIds.remove(id);
    await repository.saveAll(options);
    generateCombinations();
    notifyListeners();
  }

  void toggleCandidate(String id, bool selected) {
    if (selected) {
      selectedCandidateIds.add(id);
    } else {
      selectedCandidateIds.remove(id);
    }
    generateCombinations();
    notifyListeners();
  }

  void selectCombination(int index) {
    selectedCombinationIndex = index;
    notifyListeners();
  }

  void generateCombinations() {
    validCombinations = combinationService.generateValidCombinations(selectedCandidates);
    if (selectedCombinationIndex >= validCombinations.length) {
      selectedCombinationIndex = 0;
    }
  }
}
