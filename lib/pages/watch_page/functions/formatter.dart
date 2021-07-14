String elongate(int number) {
  if (number ~/ 10 == 0)
    return "0" + number.toString();
  else
    return number.toString();
}

String formatDuration(Duration duration, Duration model) {
  String value = elongate(duration.inMinutes % 60) +
      ":" +
      elongate(duration.inSeconds % 60);
  if (model.inHours > 0) value = elongate(duration.inHours) + ":" + value;
  return value;
}
