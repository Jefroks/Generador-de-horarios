import '../entities/course_option.dart';

abstract class CourseOptionRepository {
  Future<List<CourseOption>> getAll();
  Future<void> saveAll(List<CourseOption> options);
}
