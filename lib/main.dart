import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/schedule_controller.dart';
import 'application/schedule_combination_service.dart';
import 'data/datasources/local_course_option_datasource.dart';
import 'data/repositories/local_course_option_repository.dart';
import 'presentation/pages/schedule_planner_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final datasource = LocalCourseOptionDataSource(preferences: preferences);
  final repository = LocalCourseOptionRepository(datasource: datasource);
  final combinationService = ScheduleCombinationService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ScheduleController(
        repository: repository,
        combinationService: combinationService,
      )..load(),
      child: const SchedulePlannerApp(),
    ),
  );
}

class SchedulePlannerApp extends StatelessWidget {
  const SchedulePlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Generador de horarios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SchedulePlannerPage(),
    );
  }
}
