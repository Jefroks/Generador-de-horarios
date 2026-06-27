import 'package:flutter/material.dart';

import '../../domain/entities/week_day.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  final Set<WeekDay> selectedDays;
  final ValueChanged<Set<WeekDay>> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WeekDay.values.map((day) {
            final selected = selectedDays.contains(day);
            return FilterChip(
              visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
              label: Text(compact ? day.shortLabel : '${day.shortLabel} · ${day.label}'),
              selected: selected,
              onSelected: (value) {
                final updated = Set<WeekDay>.from(selectedDays);
                if (value) {
                  updated.add(day);
                } else {
                  updated.remove(day);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
