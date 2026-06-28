import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/schedule_controller.dart';
import '../../core/layout/app_breakpoints.dart';
import '../../domain/entities/course_option.dart';
import '../widgets/combination_bar.dart';
import '../widgets/course_option_form.dart';
import '../widgets/course_option_tile.dart';
import '../widgets/free_time_summary.dart';
import '../widgets/schedule_grid.dart';

class SchedulePlannerPage extends StatefulWidget {
  const SchedulePlannerPage({super.key});

  @override
  State<SchedulePlannerPage> createState() => _SchedulePlannerPageState();
}

class _SchedulePlannerPageState extends State<SchedulePlannerPage> {
  int _selectedMobileTab = 0;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ScheduleController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = AppBreakpoints.isDesktop(constraints.maxWidth);
        final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);

        return Scaffold(
          appBar: AppBar(
            title: Text(isMobile ? 'Horarios' : 'Generador visual de horarios'),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: isMobile ? 8 : 16),
                child: Center(
                  child: Text(
                    isMobile
                        ? '${controller.validCombinations.length} válidas'
                        : '${controller.validCombinations.length} combinaciones válidas',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: isDesktop
                      ? _DesktopLayout(controller: controller)
                      : _MobileLayout(
                          controller: controller,
                          selectedTab: _selectedMobileTab,
                        ),
                ),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: _selectedMobileTab,
                  onDestinationSelected: (index) {
                    setState(() => _selectedMobileTab = index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: 'Horario',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.tune_outlined),
                      selectedIcon: Icon(Icons.tune),
                      label: 'Opciones',
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.controller});

  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 420,
          child: _SidePanel(controller: controller),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _ScheduleArea(controller: controller)),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.controller,
    required this.selectedTab,
  });

  final ScheduleController controller;
  final int selectedTab;

  @override
  Widget build(BuildContext context) {
    if (selectedTab == 0) {
      return _ScheduleArea(controller: controller);
    }

    return _SidePanel(controller: controller);
  }
}

class _ScheduleArea extends StatelessWidget {
  const _ScheduleArea({required this.controller});

  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
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

    final width = MediaQuery.sizeOf(context).width;
    final isMobile = AppBreakpoints.isMobile(width);

    return ListView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      children: [
        const CourseOptionForm(),
        SizedBox(height: isMobile ? 12 : 16),
        FreeTimeSummary(options: controller.activeSchedule),
        SizedBox(height: isMobile ? 12 : 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.cloud_sync_outlined),
          label: const Text('Recargar JSON publicado'),
          onPressed: () => _reloadSeed(context),
        ),
        const SizedBox(height: 8),
        Text(
          'Úsalo cuando actualices web/data/professors_seed.json y quieras reemplazar la base local del navegador.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Text('Profesores cargados', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...grouped.entries.map(
          (entry) => Card(
            child: ExpansionTile(
              initiallyExpanded: !isMobile,
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
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _reloadSeed(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await controller.reloadFromPublishedSeed();
    messenger.showSnackBar(
      const SnackBar(content: Text('JSON publicado recargado en la base local.')),
    );
  }
}
