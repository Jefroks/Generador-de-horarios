import '../../domain/entities/class_session.dart';
import '../../domain/entities/time_range.dart';
import '../../domain/entities/week_day.dart';

class ClassSessionModel extends ClassSession {
  const ClassSessionModel({
    required super.day,
    required super.timeRange,
  });

  factory ClassSessionModel.fromJson(Map<String, dynamic> json) {
    return ClassSessionModel(
      day: WeekDay.fromJson(json['day'] as String),
      timeRange: TimeRange(
        start: json['start'] as String,
        end: json['end'] as String,
      ),
    );
  }

  factory ClassSessionModel.fromEntity(ClassSession entity) {
    return ClassSessionModel(day: entity.day, timeRange: entity.timeRange);
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day.name,
      'start': timeRange.start,
      'end': timeRange.end,
    };
  }
}
