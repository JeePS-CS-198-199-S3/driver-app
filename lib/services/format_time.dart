String formatTime(List<int> times) {
  if (times[1] - times[0] == 1440) {
    return '24 hours';
  }
  // Convert minutes to hours and minutes
  int startHours = times[0] ~/ 60;
  int startMinutes = times[0] % 60;
  int endHours = times[1] ~/ 60;
  int endMinutes = times[1] % 60;

  // Determine AM or PM for start and end times
  String startPeriod = (startHours >= 12 && startHours != 24
      ? 'PM'
      : 'AM');
  String endPeriod = endHours >= 12 && endHours != 24
      ? 'PM'
      : 'AM';

  // Convert hours to 12-hour format
  if (startHours > 12) {
    startHours -= 12;
  }
  if (endHours > 12) {
    endHours -= 12;
  }

  if (startHours == 0) {
    startHours = 12;
  }

  if (endHours == 0) {
    endHours = 12;
  }

  // Format the time strings
  String startTime = '$startHours:${startMinutes.toString().padLeft(2, '0')} $startPeriod';
  String endTime = '$endHours:${endMinutes.toString().padLeft(2, '0')} $endPeriod';

  return '$startTime - $endTime';
}