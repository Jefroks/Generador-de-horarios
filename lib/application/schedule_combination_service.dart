import '../domain/entities/class_session.dart';
import '../domain/entities/course_option.dart';

class ScheduleCombinationService {
  List<List<CourseOption>> generateValidCombinations(List<CourseOption> candidates) {
    final grouped = <String, List<CourseOption>>{};

    for (final option in candidates) {
      grouped.putIfAbsent(option.subject.trim(), () => []).add(option);
    }

    final subjects = grouped.keys.toList()..sort();
    final results = <List<CourseOption>>[];

    void backtrack(int index, List<CourseOption> current) {
      if (index == subjects.length) {
        results.add(List<CourseOption>.from(current));
        return;
      }

      final subject = subjects[index];
      final options = grouped[subject]!;

      for (final option in options) {
        if (!_conflictsWithSelection(option, current)) {
          current.add(option);
          backtrack(index + 1, current);
          current.removeLast();
        }
      }
    }

    backtrack(0, []);
    return results;
  }

  bool hasConflict(List<CourseOption> options) {
    for (var i = 0; i < options.length; i++) {
      for (var j = i + 1; j < options.length; j++) {
        if (_optionsOverlap(options[i], options[j])) return true;
      }
    }
    return false;
  }

  bool _conflictsWithSelection(CourseOption option, List<CourseOption> selected) {
    return selected.any((current) => _optionsOverlap(option, current));
  }

  bool _optionsOverlap(CourseOption a, CourseOption b) {
    for (final ClassSession sessionA in a.sessions) {
      for (final ClassSession sessionB in b.sessions) {
        if (sessionA.overlaps(sessionB)) return true;
      }
    }
    return false;
  }
}
