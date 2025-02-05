import 'package:chessudoku/enums/cell_type.dart';
import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/enums/game_status.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:chessudoku/models/game_state.dart';
import 'dart:convert';

GameState convertPuzzleToGameState(Map<String, dynamic> puzzleData) {
  final String puzzleId = puzzleData['id'] ?? DateTime.now().toString();
  final pieces = puzzleData['pieces'] as Map<String, dynamic>;
  final board = puzzleData['board'];
  final puzzleBoard = (board['puzzle'] as List<dynamic>).cast<Map<String, dynamic>>();
  final solutionBoard = (board['solution'] as List<dynamic>).cast<Map<String, dynamic>>();

  // Initialize empty boards
  final initialBoardCells = List.generate(9, (row) => List.generate(9, (col) => Cell(type: CellType.empty)));
  final solutionBoardCells = List.generate(9, (row) => List.generate(9, (col) => Cell(type: CellType.empty)));

  // Place chess pieces first
  pieces.forEach((pieceName, positions) {
    ChessPiece pieceType;
    switch (pieceName.toLowerCase()) {
      case 'king':
        pieceType = ChessPiece.king;
        break;
      case 'bishop':
        pieceType = ChessPiece.bishop;
        break;
      case 'knight':
        pieceType = ChessPiece.knight;
        break;
      default:
        throw Exception('Unknown piece type: $pieceName');
    }

    for (final pos in positions as List<dynamic>) {
      final row = pos['row'] as int;
      final col = pos['col'] as int;
      final cell = Cell(type: CellType.piece, piece: pieceType, isInitial: true);
      initialBoardCells[row][col] = cell;
      solutionBoardCells[row][col] = cell;
    }
  });

  // Fill puzzle board
  for (final cell in puzzleBoard) {
    final row = cell['row'] as int;
    final col = cell['col'] as int;
    final type = cell['type'] as String;
    final value = cell['value'];

    if (type == 'number' && value != null && value != '') {
      initialBoardCells[row][col] = Cell(
        type: CellType.initial,
        number: value is int ? value : int.parse(value.toString()),
        isInitial: true,
      );
    }
  }

  // Fill solution board
  for (final cell in solutionBoard) {
    final row = cell['row'] as int;
    final col = cell['col'] as int;
    final type = cell['type'] as String;
    final value = cell['value'];

    if (type == 'number') {
      solutionBoardCells[row][col] = Cell(
        type: CellType.filled,
        number: value is int ? value : int.parse(value.toString()),
        isInitial: false,
      );
    }
  }

  return GameState(
    puzzleId: puzzleId,
    status: GameStatus.playing,
    initialBoard: Board(cells: initialBoardCells),
    currentBoard: Board(cells: initialBoardCells),
    solutionBoard: Board(cells: solutionBoardCells),
    startTime: DateTime.now(),
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
