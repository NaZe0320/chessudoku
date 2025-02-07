// game_record.dart
class GameRecord {
  final String? id;
  final String difficulty;
  final int elapsedSeconds;
  final DateTime completedAt;
  final int hintsUsed;
  final String puzzleId;

  GameRecord({
    this.id,
    required this.difficulty,
    required this.elapsedSeconds,
    required this.completedAt,
    required this.hintsUsed,
    required this.puzzleId,
  });

  Map<String, dynamic> toMap() {
    return {
      'difficulty': difficulty,
      'elapsed_seconds': elapsedSeconds,
      'completed_at': completedAt.toIso8601String(),
      'hints_used': hintsUsed,
      'puzzle_id': puzzleId,
    };
  }

  factory GameRecord.fromMap(Map<String, dynamic> map) {
    return GameRecord(
      id: map['id'] as String?, // Firebase document ID는 String 타입
      difficulty: map['difficulty'] as String,
      elapsedSeconds: (map['elapsed_seconds'] as num).toInt(), // num 타입을 int로 변환
      completedAt: DateTime.parse(map['completed_at'] as String),
      hintsUsed: (map['hints_used'] as num).toInt(), // num 타입을 int로 변환
      puzzleId: map['puzzle_id'] as String,
    );
  }
}
