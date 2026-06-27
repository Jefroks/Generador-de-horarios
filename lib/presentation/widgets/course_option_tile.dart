import 'package:flutter/material.dart';

import '../../domain/entities/course_option.dart';

class CourseOptionTile extends StatelessWidget {
  const CourseOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onChanged,
    required this.onDelete,
  });

  final CourseOption option;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final sessions = option.sessions
        .map((session) => '${session.day.shortLabel} ${session.timeRange.start}-${session.timeRange.end}')
        .join(' / ');

    return CheckboxListTile(
      dense: true,
      value: selected,
      onChanged: (value) => onChanged(value ?? false),
      title: Text('${option.professor} · ${option.section}'),
      subtitle: Text(sessions),
      secondary: IconButton(
        tooltip: 'Eliminar',
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}
