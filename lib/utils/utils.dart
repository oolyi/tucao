class Utils {
  static String durationToString(Duration duration) {
    String pad(int n) => n.toString().padLeft(2, '0');
    var minutes = pad(duration.inMinutes % 60);
    var seconds = pad(duration.inSeconds % 60);
    return "$minutes:$seconds";
  }
}
