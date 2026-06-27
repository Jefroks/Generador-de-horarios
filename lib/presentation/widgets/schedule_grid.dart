import 'package:flutter/material.dart';

import '../../core/constants/app_time.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/course_option.dart';
import '../../domain/entities/week_day.dart';

class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({
    super.key,
    required this.options,
  });

  final List<CourseOption> options;

  static const double _hourHeight = 64;
  static const double _timeColumnWidth = 72;
  static const double _dayColumnWidth = 190;

  @override
  Widget build(BuildContext context) {
    final totalHeight = (AppTime.endHour - AppTime.startHour) * _hourHeight;

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _timeColumnWidth + (WeekDay.values.length * _dayColumnWidth),
          child: Column(
            children: [
              _HeaderRow(timeColumnWidth: _timeColumnWidth, dayColumnWidth: _dayColumnWidth),
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: totalHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TimeColumn(hourHeight: _hourHeight, width: _timeColumnWidth),
                        ...WeekDay.values.map(
                          (day) => _DayColumn(
                            day: day,
                            options: options,
                            width: _dayColumnWidth,
                            hourHeight: _hourHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.timeColumnWidth, required this.dayColumnWidth});

  final double timeColumnWidth;
  final double dayColumnWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          SizedBox(width: timeColumnWidth, child: const Center(child: Text('Hora'))),
          ...WeekDay.values.map(
            (day) => Container(
              width: dayColumnWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Text(day.label, style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({required this.hourHeight, required this.width});

  final double hourHeight;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: List.generate(AppTime.endHour - AppTime.startHour, (index) {
          final hour = AppTime.startHour + index;
          return Container(
            height: hourHeight,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Text('${hour.toString().padLeft(2, '0')}:00'),
          );
        }),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.options,
    required this.width,
    required this.hourHeight,
  });

  final WeekDay day;
  final List<CourseOption> options;
  final double width;
  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    final daySessions = <_VisualClass>[];

    for (final option in options) {
      for (final session in option.sessions.where((session) => session.day == day)) {
        daySessions.add(_VisualClass(option: option, sessionStart: session.timeRange.start, sessionEnd: session.timeRange.end));
      }
    }

    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Stack(
        children: [
          Column(
            children: List.generate(AppTime.endHour - AppTime.startHour, (index) {
              return Container(
                height: hourHeight,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.6))),
                ),
              );
            }),
          ),
          ...daySessions.map((visualClass) {
            final start = TimeUtils.parseTimeToMinutes(visualClass.sessionStart);
            final end = TimeUtils.parseTimeToMinutes(visualClass.sessionEnd);
            final top = ((start - AppTime.startMinutes) / 60) * hourHeight;
            final height = ((end - start) / 60) * hourHeight;

            return Positioned(
              left: 8,
              right: 8,
              top: top + 2,
              height: height - 4,
              child: _ClassBlock(visualClass: visualClass),
            );
          }),
        ],
      ),
    );
  }
}

class _ClassBlock extends StatelessWidget {
  const _ClassBlock({required this.visualClass});

  final _VisualClass visualClass;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(visualClass.option.subject, context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FittedBox(
        alignment: Alignment.topLeft,
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                visualClass.option.subject,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                visualClass.option.professor,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${visualClass.sessionStart}-${visualClass.sessionEnd} · ${visualClass.option.section}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFor(String value, BuildContext context) {
    final colors = <Color>[
      Colors.indigo,
      Colors.teal,
      Colors.deepOrange,
      Colors.purple,
      Colors.blueGrey,
      Colors.brown,
      Colors.green,
      Colors.pink,
    ];
    final index = value.hashCode.abs() % colors.length;
    return colors[index];
  }
}

class _VisualClass {
  const _VisualClass({
    required this.option,
    required this.sessionStart,
    required this.sessionEnd,
  });

  final CourseOption option;
  final String sessionStart;
  final String sessionEnd;
}
