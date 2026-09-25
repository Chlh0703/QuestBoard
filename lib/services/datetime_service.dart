class DateTimeService {
  static String formatRemainingTime(DateTime? dueDate) {
    if (dueDate == null) {
      return '';
    }

    final remaining = dueDate.difference(DateTime.now());

    if (remaining.isNegative || remaining.inSeconds <= 0) {
      return 'Due';
    }

    if (remaining.inHours >= 24) {
      return '${remaining.inDays}d';
    }

    if (remaining.inMinutes >= 60) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes.remainder(60);

      return '${hours}h ${minutes}m';
    }

    if (remaining.inSeconds >= 60) {
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds.remainder(60);

      return '${minutes}m ${seconds}s';
    }

    return '${remaining.inSeconds}s';
  }

  static String formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
    );
  }
}