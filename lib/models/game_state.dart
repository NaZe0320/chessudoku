import 'package:chessudoku/enums/cell_type.dart';
import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/enums/game_status.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:equatable/equatable.dart';

class GameState extends Equatable {
  final String puzzleId;
  final GameStatus status;
  final List<List<Cell>> initialBoard; // 초기 보드 상태 (9x9)
  final List<List<Cell>> currentBoard; // 현재 보드 상태 (9x9)
  final List<List<Cell>> solutionBoard; // 완성된 보드 상태 (9x9)
  final int hintsUsed; // 사용된 힌트 횟수
  final DateTime startTime; // 게임 시작 시간
  final int elapsedSeconds; // 진행 시간 (초)
  final List<int> selectedCell; // 현재 선택된 셀 위치 [row, col]

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

  // 게임이 완료되었는지 확인
  bool get isCompleted => status == GameStatus.completed;

  // 게임이 진행 중인지 확인
  bool get isPlaying => status == GameStatus.playing;

  // 선택된 셀이 있는지 확인
  bool get hasSelectedCell => selectedCell[0] != -1 && selectedCell[1] != -1;

  // 현재 선택된 셀의 타입 확인
  CellType? get selectedCellType {
    if (!hasSelectedCell) return null;
    return currentBoard[selectedCell[0]][selectedCell[1]].type;
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'puzzleId': puzzleId,
      'status': status.toString(),
      'initialBoard':
          initialBoard
              .map(
                (row) =>
                    row
                        .map(
                          (cell) => {
                            'type': cell.type.toString(),
                            'number': cell.number,
                            'piece': cell.piece?.toString(),
                            'isInitial': cell.isInitial,
                          },
                        )
                        .toList(),
              )
              .toList(),
      'currentBoard':
          currentBoard
              .map(
                (row) =>
                    row
                        .map(
                          (cell) => {
                            'type': cell.type.toString(),
                            'number': cell.number,
                            'piece': cell.piece?.toString(),
                            'isInitial': cell.isInitial,
                          },
                        )
                        .toList(),
              )
              .toList(),
      'solutionBoard':
          solutionBoard
              .map(
                (row) =>
                    row
                        .map(
                          (cell) => {
                            'type': cell.type.toString(),
                            'number': cell.number,
                            'piece': cell.piece?.toString(),
                            'isInitial': cell.isInitial,
                          },
                        )
                        .toList(),
              )
              .toList(),
      'hintsUsed': hintsUsed,
      'startTime': startTime.toIso8601String(),
      'elapsedSeconds': elapsedSeconds,
      'selectedCell': selectedCell,
    };
  }

  // JSON 역직렬화
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      puzzleId: json['puzzleId'],
      status: GameStatus.values.firstWhere((e) => e.toString() == json['status']),
      initialBoard:
          (json['initialBoard'] as List)
              .map(
                (row) =>
                    (row as List)
                        .map(
                          (cell) => Cell(
                            type: CellType.values.firstWhere((e) => e.toString() == cell['type']),
                            number: cell['number'],
                            piece:
                                cell['piece'] != null
                                    ? ChessPiece.values.firstWhere((e) => e.toString() == cell['piece'])
                                    : null,
                            isInitial: cell['isInitial'],
                          ),
                        )
                        .toList(),
              )
              .toList(),
      currentBoard:
          (json['currentBoard'] as List)
              .map(
                (row) =>
                    (row as List)
                        .map(
                          (cell) => Cell(
                            type: CellType.values.firstWhere((e) => e.toString() == cell['type']),
                            number: cell['number'],
                            piece:
                                cell['piece'] != null
                                    ? ChessPiece.values.firstWhere((e) => e.toString() == cell['piece'])
                                    : null,
                            isInitial: cell['isInitial'],
                          ),
                        )
                        .toList(),
              )
              .toList(),
      solutionBoard:
          (json['solutionBoard'] as List)
              .map(
                (row) =>
                    (row as List)
                        .map(
                          (cell) => Cell(
                            type: CellType.values.firstWhere((e) => e.toString() == cell['type']),
                            number: cell['number'],
                            piece:
                                cell['piece'] != null
                                    ? ChessPiece.values.firstWhere((e) => e.toString() == cell['piece'])
                                    : null,
                            isInitial: cell['isInitial'],
                          ),
                        )
                        .toList(),
              )
              .toList(),
      hintsUsed: json['hintsUsed'],
      startTime: DateTime.parse(json['startTime']),
      elapsedSeconds: json['elapsedSeconds'],
      selectedCell: List<int>.from(json['selectedCell']),
    );
  }

  // 상태 복사 및 업데이트
  GameState copyWith({
    String? puzzleId,
    GameStatus? status,
    List<List<Cell>>? initialBoard,
    List<List<Cell>>? currentBoard,
    List<List<Cell>>? solutionBoard,
    int? hintsUsed,
    int? maxHints,
    DateTime? startTime,
    int? elapsedSeconds,
    List<int>? selectedCell,
    bool? showHints,
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
