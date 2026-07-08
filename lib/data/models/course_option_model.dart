import '../../domain/entities/class_session.dart';
import '../../domain/entities/course_option.dart';
import 'class_session_model.dart';

class CourseOptionModel extends CourseOption {
  const CourseOptionModel({
    required super.id,
    required super.subject,
    required super.professor,
    required super.section,
    required super.nrc,
    required super.sessions,
  });

  factory CourseOptionModel.fromJson(Map<String, dynamic> json) {
    return CourseOptionModel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      professor: json['professor'] as String,
      section: json['section'] as String? ?? '',
      nrc: _readString(json['nrc']),
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
      nrc: entity.nrc,
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
      'nrc': nrc,
      'sessions': sessions
          .map((session) => ClassSessionModel.fromEntity(session).toJson())
          .toList(),
    };
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}
