import 'package:flutter/material.dart';

import '../../core/constants/app_time.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/course_option.dart';
import '../../domain/entities/week_day.dart';

class FreeTimeSummary extends StatelessWidget {
  const FreeTimeSummary({
    super.key,
    required this.options,
  });

  final List<CourseOption> options;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Horas libres por día', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...WeekDay.values.map((day) {
              final freeBlocks = _freeBlocksForDay(day);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${day.shortLabel}: ${freeBlocks.isEmpty ? 'Sin huecos' : freeBlocks.join(' / ')}'),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<String> _freeBlocksForDay(WeekDay day) {
    final busy = <({int start, int end})>[];

    for (final option in options) {
      for (final session in option.sessions.where((session) => session.day == day)) {
        busy.add((
          start: session.timeRange.startMinutes,
          end: session.timeRange.endMinutes,
        ));
      }
    }

    busy.sort((a, b) => a.start.compareTo(b.start));

    final free = <String>[];
    var cursor = AppTime.startMinutes;

    for (final block in busy) {
      if (block.start > cursor) {
        free.add('${TimeUtils.minutesToTime(cursor)}-${TimeUtils.minutesToTime(block.start)}');
      }
      if (block.end > cursor) cursor = block.end;
    }

    if (cursor < AppTime.endMinutes) {
      free.add('${TimeUtils.minutesToTime(cursor)}-${TimeUtils.minutesToTime(AppTime.endMinutes)}');
    }

    return free;
  }
}
