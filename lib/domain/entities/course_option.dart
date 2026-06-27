import 'class_session.dart';

class CourseOption {
  const CourseOption({
    required this.id,
    required this.subject,
    required this.professor,
    required this.section,
    required this.sessions,
  });

  final String id;
  final String subject;
  final String professor;
  final String section;
  final List<ClassSession> sessions;

  String get displayName => '$subject · $professor · $section';
}
