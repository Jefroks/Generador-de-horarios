import 'class_session.dart';

class CourseOption {
  const CourseOption({
    required this.id,
    required this.subject,
    required this.professor,
    required this.section,
    required this.nrc,
    required this.sessions,
  });

  final String id;
  final String subject;
  final String professor;
  final String section;
  final String nrc;
  final List<ClassSession> sessions;

  String get displayName {
    final nrcLabel = nrc.trim().isEmpty ? '' : ' · NRC $nrc';
    return '$subject · $professor · $section$nrcLabel';
  }
}
