import 'package:chessudoku/enums/cell_type.dart';
import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/enums/game_status.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/models/move_history.dart';
import 'package:equatable/equatable.dart';

class GameState extends Equatable {
  static const int maxChecks = 3; // 최대 체크 횟수
  final String puzzleId;
  final String difficulty;
  final GameStatus status;
  final Board initialBoard;
  final Board currentBoard;
  final Board solutionBoard;
  final int hintsUsed;
  final DateTime startTime;
  final int elapsedSeconds;
  final List<int> selectedCell;
  final MoveHistory moveHistory;
  final int remainingChecks; // 남은 체크 횟수

  const GameState({
    required this.puzzleId,
    required this.difficulty, // 난이도 필수 파라미터로 추가
    required this.status,
    required this.initialBoard,
    required this.currentBoard,
    required this.solutionBoard,
    this.hintsUsed = 0,
    required this.startTime,
    this.elapsedSeconds = 0,
    this.selectedCell = const [-1, -1],
    this.moveHistory = const MoveHistory(),
    this.remainingChecks = maxChecks,
  });

  bool get isCompleted => status == GameStatus.completed;
  bool get isPlaying => status == GameStatus.playing;
  bool get hasSelectedCell => selectedCell[0] != -1 && selectedCell[1] != -1;
  bool get canUndo => moveHistory.canUndo;
  bool get canCheck => remainingChecks > 0;

  CellType? get selectedCellType {
    if (!hasSelectedCell) return null;
    return currentBoard.getCell(selectedCell[0], selectedCell[1]).type;
  }

  Map<String, dynamic> toJson() {
    return {
      'puzzleId': puzzleId,
      'difficulty': difficulty, // JSON 직렬화에 난이도 추가
      'status': status.toString(),
      'initialBoard': initialBoard.toJson(),
      'currentBoard': currentBoard.toJson(),
      'solutionBoard': solutionBoard.toJson(),
      'hintsUsed': hintsUsed,
      'startTime': startTime.toIso8601String(),
      'elapsedSeconds': elapsedSeconds,
      'selectedCell': selectedCell,
      'moveHistory': moveHistory.toJson(),
      'remainingChecks': remainingChecks,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      puzzleId: json['puzzleId'],
      difficulty: json['difficulty'], // JSON 역직렬화에 난이도 추가
      status: GameStatus.values.firstWhere((e) => e.toString() == json['status']),
      initialBoard: Board.fromJson(json['initialBoard']),
      currentBoard: Board.fromJson(json['currentBoard']),
      solutionBoard: Board.fromJson(json['solutionBoard']),
      hintsUsed: json['hintsUsed'],
      startTime: DateTime.parse(json['startTime']),
      elapsedSeconds: json['elapsedSeconds'],
      selectedCell: List<int>.from(json['selectedCell']),
      moveHistory: MoveHistory.fromJson(json['moveHistory']),
      remainingChecks: json['remainingChecks'] ?? maxChecks,
    );
  }

  GameState copyWith({
    String? puzzleId,
    String? difficulty, // copyWith에 난이도 추가
    GameStatus? status,
    Board? initialBoard,
    Board? currentBoard,
    Board? solutionBoard,
    int? hintsUsed,
    DateTime? startTime,
    int? elapsedSeconds,
    List<int>? selectedCell,
    MoveHistory? moveHistory,
    int? remainingChecks,
  }) {
    return GameState(
      puzzleId: puzzleId ?? this.puzzleId,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      initialBoard: initialBoard ?? this.initialBoard,
      currentBoard: currentBoard ?? this.currentBoard,
      solutionBoard: solutionBoard ?? this.solutionBoard,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      startTime: startTime ?? this.startTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      selectedCell: selectedCell ?? this.selectedCell,
      moveHistory: moveHistory ?? this.moveHistory,
      remainingChecks: remainingChecks ?? this.remainingChecks,
    );
  }

  @override
  List<Object?> get props => [
    puzzleId,
    difficulty,
    status,
    initialBoard,
    currentBoard,
    solutionBoard,
    hintsUsed,
    startTime,
    elapsedSeconds,
    selectedCell,
    moveHistory,
    remainingChecks,
  ];
}
