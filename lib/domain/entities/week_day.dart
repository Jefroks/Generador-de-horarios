enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday;

  String get shortLabel {
    switch (this) {
      case WeekDay.monday:
        return 'L';
      case WeekDay.tuesday:
        return 'A';
      case WeekDay.wednesday:
        return 'M';
      case WeekDay.thursday:
        return 'J';
      case WeekDay.friday:
        return 'V';
    }
  }

  String get label {
    switch (this) {
      case WeekDay.monday:
        return 'Lunes';
      case WeekDay.tuesday:
        return 'Martes';
      case WeekDay.wednesday:
        return 'Miércoles';
      case WeekDay.thursday:
        return 'Jueves';
      case WeekDay.friday:
        return 'Viernes';
    }
  }

  static WeekDay fromJson(String value) {
    return WeekDay.values.firstWhere(
      (day) => day.name == value,
      orElse: () => WeekDay.monday,
    );
  }
}
