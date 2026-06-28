import '../../domain/entities/course_option.dart';
import '../../domain/repositories/course_option_repository.dart';
import '../datasources/local_course_option_datasource.dart';
import '../models/course_option_model.dart';

class LocalCourseOptionRepository implements CourseOptionRepository {
  LocalCourseOptionRepository({required this.datasource});

  final LocalCourseOptionDataSource datasource;

  @override
  Future<List<CourseOption>> getAll() {
    return datasource.getAll();
  }

  @override
  Future<void> saveAll(List<CourseOption> options) {
    return datasource.saveAll(
      options.map((option) => CourseOptionModel.fromEntity(option)).toList(),
    );
  }

  @override
  Future<List<CourseOption>> reloadFromPublishedSeed() {
    return datasource.reloadFromPublishedSeed();
  }
}
