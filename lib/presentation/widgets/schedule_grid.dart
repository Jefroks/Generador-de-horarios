import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_time.dart';
import '../../core/layout/app_breakpoints.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/course_option.dart';
import '../../domain/entities/week_day.dart';

class ScheduleGrid extends StatefulWidget {
  const ScheduleGrid({
    super.key,
    required this.options,
  });

  final List<CourseOption> options;

  @override
  State<ScheduleGrid> createState() => _ScheduleGridState();
}

class _ScheduleGridState extends State<ScheduleGrid> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppBreakpoints.isMobile(constraints.maxWidth);
        final isTablet = AppBreakpoints.isTablet(constraints.maxWidth);

        final hourHeight = isMobile ? 72.0 : 64.0;
        final timeColumnWidth = isMobile ? 56.0 : 72.0;
        final minDayWidth = isMobile ? 112.0 : (isTablet ? 148.0 : 190.0);
        final availableDayWidth = (constraints.maxWidth - timeColumnWidth) / WeekDay.values.length;
        final dayColumnWidth = math.max(minDayWidth, availableDayWidth);
        final gridWidth = timeColumnWidth + (WeekDay.values.length * dayColumnWidth);
        final totalHeight = (AppTime.endHour - AppTime.startHour) * hourHeight;

        return Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          notificationPredicate: (notification) => notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: gridWidth,
              child: Column(
                children: [
                  _HeaderRow(
                    timeColumnWidth: timeColumnWidth,
                    dayColumnWidth: dayColumnWidth,
                    compact: isMobile,
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _verticalController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _verticalController,
                        child: SizedBox(
                          height: totalHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TimeColumn(
                                hourHeight: hourHeight,
                                width: timeColumnWidth,
                                compact: isMobile,
                              ),
                              ...WeekDay.values.map(
                                (day) => _DayColumn(
                                  day: day,
                                  options: widget.options,
                                  width: dayColumnWidth,
                                  hourHeight: hourHeight,
                                  compact: isMobile,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.timeColumnWidth,
    required this.dayColumnWidth,
    required this.compact,
  });

  final double timeColumnWidth;
  final double dayColumnWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 42 : 48,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: timeColumnWidth,
            child: Center(
              child: Text(
                'Hora',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          ...WeekDay.values.map(
            (day) => Container(
              width: dayColumnWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Text(
                compact ? day.shortLabel : day.label,
                style: compact
                    ? Theme.of(context).textTheme.labelLarge
                    : Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.hourHeight,
    required this.width,
    required this.compact,
  });

  final double hourHeight;
  final double width;
  final bool compact;

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
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: compact ? Theme.of(context).textTheme.labelSmall : null,
            ),
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
    required this.compact,
  });

  final WeekDay day;
  final List<CourseOption> options;
  final double width;
  final double hourHeight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final daySessions = <_VisualClass>[];

    for (final option in options) {
      for (final session in option.sessions.where((session) => session.day == day)) {
        daySessions.add(
          _VisualClass(
            option: option,
            sessionStart: session.timeRange.start,
            sessionEnd: session.timeRange.end,
          ),
        );
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
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.6)),
                  ),
                ),
              );
            }),
          ),
          ...daySessions.map((visualClass) {
            final start = TimeUtils.parseTimeToMinutes(visualClass.sessionStart);
            final end = TimeUtils.parseTimeToMinutes(visualClass.sessionEnd);
            final top = ((start - AppTime.startMinutes) / 60) * hourHeight;
            final height = math.max(36.0, ((end - start) / 60) * hourHeight - 4);
            final horizontalInset = compact ? 4.0 : 8.0;

            return Positioned(
              left: horizontalInset,
              right: horizontalInset,
              top: top + 2,
              height: height,
              child: _ClassBlock(
                visualClass: visualClass,
                compact: compact,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ClassBlock extends StatelessWidget {
  const _ClassBlock({
    required this.visualClass,
    required this.compact,
  });

  final _VisualClass visualClass;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(visualClass.option.subject, context);

    return Container(
      padding: EdgeInsets.all(compact ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
      ),
      child: FittedBox(
        alignment: Alignment.topLeft,
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: compact ? 96 : 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                visualClass.option.subject,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? Theme.of(context).textTheme.labelMedium
                    : Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                visualClass.option.professor,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${visualClass.sessionStart}-${visualClass.sessionEnd}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (!compact)
                Text(
                  visualClass.option.section,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
