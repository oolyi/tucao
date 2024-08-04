class Utils {
  static String durationToString(Duration duration) {
    String pad(int n) => n.toString().padLeft(2, '0');

    var hours = duration.inHours;
    var minutes = duration.inMinutes % 60;
    var seconds = duration.inSeconds % 60;

    if (hours > 0) {
      // 如果有小时数，则输出 hh:mm:ss 格式
      return "${pad(hours)}:${pad(minutes)}:${pad(seconds)}";
    } else {
      // 如果没有小时数，则输出 mm:ss 格式，即使分钟数为零
      return "${pad(minutes)}:${pad(seconds)}";
    }
  }
}
