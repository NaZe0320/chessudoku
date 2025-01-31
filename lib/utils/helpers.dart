import 'dart:math' as math;

/// 주어진 범위 내의 랜덤 정수를 반환합니다.
/// [min]은 포함되고 [max]는 포함되지 않습니다.
int getRandomInt(int min, int max) {
  return min + math.Random().nextInt(max - min);
}

/// 밀리초를 MM:SS 형식의 문자열로 변환합니다.
String formatDuration(int milliseconds) {
  final seconds = (milliseconds / 1000).floor();
  final minutes = (seconds / 60).floor();
  final remainingSeconds = seconds % 60;

  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

/// 숫자를 자릿수 단위로 포맷팅합니다. (예: 1000 -> 1,000)
String formatNumber(int number) {
  return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
}

/// 날짜를 yyyy-MM-dd 형식의 문자열로 변환합니다.
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// 디바이스 해상도에 따른 적절한 크기를 계산합니다.
double getResponsiveSize(double baseSize, double screenWidth) {
  final ratio = screenWidth / 360.0; // 360은 기준 너비
  return baseSize * ratio;
}
