import 'package:chessudoku/enums/cell_type.dart';
import 'package:equatable/equatable.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/enums/game_status.dart';

class GameState extends Equatable {
  final String puzzleId;
  final GameStatus status;
  final Board initialBoard;
  final Board currentBoard;
  final Board solutionBoard;
  final int hintsUsed;
  final DateTime startTime;
  final int elapsedSeconds;
  final List<int> selectedCell;

  const GameState({
    required this.puzzleId,
    required this.status,
    required this.initialBoard,
    required this.currentBoard,
    required this.solutionBoard,
    this.hintsUsed = 0,
    required this.startTime,
    this.elapsedSeconds = 0,
    this.selectedCell = const [-1, -1],
  });

  bool get isCompleted => status == GameStatus.completed;
  bool get isPlaying => status == GameStatus.playing;
  bool get hasSelectedCell => selectedCell[0] != -1 && selectedCell[1] != -1;

  CellType? get selectedCellType {
    if (!hasSelectedCell) return null;
    return currentBoard.getCell(selectedCell[0], selectedCell[1]).type;
  }

  Map<String, dynamic> toJson() {
    return {
      'puzzleId': puzzleId,
      'status': status.toString(),
      'initialBoard': initialBoard.toJson(),
      'currentBoard': currentBoard.toJson(),
      'solutionBoard': solutionBoard.toJson(),
      'hintsUsed': hintsUsed,
      'startTime': startTime.toIso8601String(),
      'elapsedSeconds': elapsedSeconds,
      'selectedCell': selectedCell,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      puzzleId: json['puzzleId'],
      status: GameStatus.values.firstWhere((e) => e.toString() == json['status']),
      initialBoard: Board.fromJson(json['initialBoard']),
      currentBoard: Board.fromJson(json['currentBoard']),
      solutionBoard: Board.fromJson(json['solutionBoard']),
      hintsUsed: json['hintsUsed'],
      startTime: DateTime.parse(json['startTime']),
      elapsedSeconds: json['elapsedSeconds'],
      selectedCell: List<int>.from(json['selectedCell']),
    );
  }

  GameState copyWith({
    String? puzzleId,
    GameStatus? status,
    Board? initialBoard,
    Board? currentBoard,
    Board? solutionBoard,
    int? hintsUsed,
    DateTime? startTime,
    int? elapsedSeconds,
    List<int>? selectedCell,
  }) {
    return GameState(
      puzzleId: puzzleId ?? this.puzzleId,
      status: status ?? this.status,
      initialBoard: initialBoard ?? this.initialBoard,
      currentBoard: currentBoard ?? this.currentBoard,
      solutionBoard: solutionBoard ?? this.solutionBoard,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      startTime: startTime ?? this.startTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      selectedCell: selectedCell ?? this.selectedCell,
    );
  }

  @override
  List<Object?> get props => [
    puzzleId,
    status,
    initialBoard,
    currentBoard,
    solutionBoard,
    hintsUsed,
    startTime,
    elapsedSeconds,
    selectedCell,
  ];
}
