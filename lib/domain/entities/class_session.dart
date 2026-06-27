import 'time_range.dart';
import 'week_day.dart';

class ClassSession {
  const ClassSession({
    required this.day,
    required this.timeRange,
  });

  final WeekDay day;
  final TimeRange timeRange;

  bool overlaps(ClassSession other) {
    return day == other.day && timeRange.overlaps(other.timeRange);
  }
}
