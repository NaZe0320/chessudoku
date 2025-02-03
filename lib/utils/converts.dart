import 'package:chessudoku/enums/cell_type.dart';
import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/enums/game_status.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:chessudoku/models/game_state.dart';
import 'dart:convert';

ChessPiece _getPieceType(String pieceName) {
  switch (pieceName.toLowerCase()) {
    case 'king':
      return ChessPiece.king;
    case 'bishop':
      return ChessPiece.bishop;
    case 'knight':
      return ChessPiece.knight;
    case 'rook':
      return ChessPiece.rook;
    default:
      throw Exception('Unknown piece type: $pieceName');
  }
}

GameState convertPuzzleToGameState(Map<String, dynamic> puzzleData) {
  final String puzzleId = puzzleData['id'] ?? DateTime.now().toString();
  final pieces = puzzleData['pieces'] as Map<String, dynamic>;
  final removedCells =
      (puzzleData['removedCells'] as List<dynamic>)
          .map((cell) => MapEntry(cell['row'] as int, cell['col'] as int))
          .toList();

  // 9x9 보드 초기화
  final initialBoardCells = List.generate(9, (row) => List.generate(9, (col) => Cell(type: CellType.empty)));

  // solution board 초기화 (모든 셀을 1-9로 채움)
  final solutionBoardCells = List.generate(
    9,
    (row) => List.generate(
      9,
      (col) => Cell(
        type: CellType.filled,
        number: ((row * 3 + row / 3 + col) % 9 + 1).floor(), // 임시로 1-9 채우기
        isInitial: false,
      ),
    ),
  );

  // 체스 기물 배치
  pieces.forEach((pieceName, positions) {
    final pieceType = _getPieceType(pieceName);
    (positions as List<dynamic>).forEach((pos) {
      final row = pos['row'] as int;
      final col = pos['col'] as int;

      initialBoardCells[row][col] = Cell(type: CellType.piece, piece: pieceType, isInitial: true);

      solutionBoardCells[row][col] = Cell(type: CellType.piece, piece: pieceType, isInitial: true);
    });
  });

  // removedCells를 제외한 나머지 셀들을 initial 타입으로 설정
  for (int row = 0; row < 9; row++) {
    for (int col = 0; col < 9; col++) {
      if (initialBoardCells[row][col].type != CellType.piece) {
        bool isRemoved = removedCells.any((cell) => cell.key == row && cell.value == col);

        if (!isRemoved) {
          initialBoardCells[row][col] = Cell(
            type: CellType.initial,
            number: solutionBoardCells[row][col].number,
            isInitial: true,
          );
        }
      }
    }
  }

  final initialBoard = Board(cells: initialBoardCells);
  final solutionBoard = Board(cells: solutionBoardCells);

  return GameState(
    puzzleId: puzzleId,
    status: GameStatus.playing,
    initialBoard: initialBoard,
    currentBoard: initialBoard,
    solutionBoard: solutionBoard,
    startTime: DateTime.now(),
    selectedCell: [-1, -1],
    hintsUsed: 0,
    elapsedSeconds: 0,
  );
}

GameState? convertJsonToGameState(String jsonString) {
  try {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return GameState.fromJson(json);
  } catch (e) {
    print('Error converting JSON to GameState: $e');
    return null;
  }
}
