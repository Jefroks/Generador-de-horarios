import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/schedule_controller.dart';
import '../../domain/entities/course_option.dart';
import '../widgets/combination_bar.dart';
import '../widgets/course_option_form.dart';
import '../widgets/course_option_tile.dart';
import '../widgets/free_time_summary.dart';
import '../widgets/schedule_grid.dart';

class SchedulePlannerPage extends StatelessWidget {
  const SchedulePlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ScheduleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador visual de horarios'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${controller.validCombinations.length} combinaciones válidas',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 420,
                  child: _SidePanel(controller: controller),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    children: [
                      CombinationBar(
                        combinations: controller.validCombinations,
                        selectedIndex: controller.selectedCombinationIndex,
                        onSelected: controller.selectCombination,
                      ),
                      Expanded(
                        child: ScheduleGrid(options: controller.activeSchedule),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.controller});

  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<CourseOption>>{};
    for (final option in controller.options) {
      grouped.putIfAbsent(option.subject, () => []).add(option);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CourseOptionForm(),
        const SizedBox(height: 16),
        FreeTimeSummary(options: controller.activeSchedule),
        const SizedBox(height: 16),
        Text('Profesores cargados', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...grouped.entries.map(
          (entry) => Card(
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text(entry.key),
              children: entry.value
                  .map(
                    (option) => CourseOptionTile(
                      option: option,
                      selected: controller.selectedCandidateIds.contains(option.id),
                      onChanged: (selected) => controller.toggleCandidate(option.id, selected),
                      onDelete: () => controller.deleteOption(option.id),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
