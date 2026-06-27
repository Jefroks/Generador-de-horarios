import '../../core/utils/time_utils.dart';

class TimeRange {
  const TimeRange({
    required this.start,
    required this.end,
  });

  final String start;
  final String end;

  int get startMinutes => TimeUtils.parseTimeToMinutes(start);
  int get endMinutes => TimeUtils.parseTimeToMinutes(end);

  bool overlaps(TimeRange other) {
    return startMinutes < other.endMinutes && endMinutes > other.startMinutes;
  }

  bool get isValid => TimeUtils.isWithinBaseSchedule(start, end);
}
