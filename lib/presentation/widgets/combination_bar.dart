import 'package:flutter/material.dart';

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
    if (combinations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Text('No hay combinaciones válidas con las opciones seleccionadas.'),
      );
    }

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: combinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ChoiceChip(
            selected: selectedIndex == index,
            label: Text('Opción ${index + 1}'),
            onSelected: (_) => onSelected(index),
          );
        },
      ),
    );
  }
}
