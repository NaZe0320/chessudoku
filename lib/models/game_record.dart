// game_record.dart
class GameRecord {
  final String? id;
  final String difficulty;
  final int elapsedSeconds;
  final DateTime completedAt;
  final int hintsUsed;
  final String puzzleId;
  final int? rating;       // 추가: 1-5 점 평가
  final String? comment;   // 추가: 선택적 코멘트

  GameRecord({
    this.id,
    required this.difficulty,
    required this.elapsedSeconds,
    required this.completedAt,
    required this.hintsUsed,
    required this.puzzleId,
    this.rating,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'difficulty': difficulty,
      'elapsed_seconds': elapsedSeconds,
      'completed_at': completedAt.toIso8601String(),
      'hints_used': hintsUsed,
      'puzzle_id': puzzleId,
      'rating': rating,
      'comment': comment,
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
      rating: map['rating'] as int?,
      comment: map['comment'] as String?,
    );
  }
}
