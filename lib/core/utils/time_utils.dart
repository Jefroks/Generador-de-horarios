class TimeUtils {
  static int parseTimeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      throw FormatException('La hora debe tener formato HH:mm', value);
    }

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw FormatException('Hora fuera de rango', value);
    }

    return (hour * 60) + minute;
  }

  static String minutesToTime(int totalMinutes) {
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static bool isWithinBaseSchedule(String start, String end) {
    final startMinutes = parseTimeToMinutes(start);
    final endMinutes = parseTimeToMinutes(end);
    return startMinutes >= 7 * 60 && endMinutes <= 21 * 60 && startMinutes < endMinutes;
  }
}
