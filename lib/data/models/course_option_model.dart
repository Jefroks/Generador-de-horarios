import '../../domain/entities/class_session.dart';
import '../../domain/entities/course_option.dart';
import 'class_session_model.dart';

class CourseOptionModel extends CourseOption {
  const CourseOptionModel({
    required super.id,
    required super.subject,
    required super.professor,
    required super.section,
    required super.sessions,
  });

  factory CourseOptionModel.fromJson(Map<String, dynamic> json) {
    return CourseOptionModel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      professor: json['professor'] as String,
      section: json['section'] as String? ?? '',
      sessions: (json['sessions'] as List<dynamic>)
          .map((item) => ClassSessionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory CourseOptionModel.fromEntity(CourseOption entity) {
    return CourseOptionModel(
      id: entity.id,
      subject: entity.subject,
      professor: entity.professor,
      section: entity.section,
      sessions: entity.sessions
          .map((ClassSession session) => ClassSessionModel.fromEntity(session))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'professor': professor,
      'section': section,
      'sessions': sessions
          .map((session) => ClassSessionModel.fromEntity(session).toJson())
          .toList(),
    };
  }
}
