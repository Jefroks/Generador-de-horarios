import 'package:flutter/material.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../domain/entities/course_option.dart';

class CombinationBar extends StatelessWidget {
  const CombinationBar({
    super.key,
    required this.combinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<List<CourseOption>> combinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = AppBreakpoints.isMobile(width);

    if (combinations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 10 : 12),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Text(
          'No hay combinaciones válidas con las opciones seleccionadas.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Container(
      height: isMobile ? 58 : 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 8),
      child: Row(
        children: [
          if (!isMobile) ...[
            Text(
              'Combinaciones',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: combinations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ChoiceChip(
                  visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                  selected: selectedIndex == index,
                  label: Text(isMobile ? 'Op. ${index + 1}' : 'Opción ${index + 1}'),
                  onSelected: (_) => onSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
