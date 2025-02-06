class GameRecord {
  final int? id;
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
      'id': id,
      'difficulty': difficulty,
      'elapsed_seconds': elapsedSeconds,
      'completed_at': completedAt.toIso8601String(),
      'hints_used': hintsUsed,
      'puzzle_id': puzzleId,
    };
  }

  factory GameRecord.fromMap(Map<String, dynamic> map) {
    return GameRecord(
      id: map['id'] as int?,
      difficulty: map['difficulty'] as String,
      elapsedSeconds: map['elapsed_seconds'] as int,
      completedAt: DateTime.parse(map['completed_at'] as String),
      hintsUsed: map['hints_used'] as int,
      puzzleId: map['puzzle_id'] as String,
    );
  }
}
