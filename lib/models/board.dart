import 'package:equatable/equatable.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/enums/cell_type.dart';

class Board extends Equatable {
  final List<List<Cell>> cells;
  static const int size = 9;

  Board({required this.cells}) : assert(cells.length == size && cells.every((row) => row.length == size));

  // 특정 위치의 셀 가져오기
  Cell getCell(int row, int col) => cells[row][col];

  // 특정 위치의 셀 업데이트
  Board updateCell(int row, int col, Cell newCell) {
    final newCells = List<List<Cell>>.from(cells.map((row) => List<Cell>.from(row)));
    newCells[row][col] = newCell;
    return Board(cells: newCells);
  }

  // 특정 행 가져오기
  List<Cell> getRow(int row) => cells[row];

  // 특정 열 가져오기
  List<Cell> getColumn(int col) => cells.map((row) => row[col]).toList();

  // 특정 3x3 박스 가져오기
  List<Cell> getBox(int row, int col) {
    final boxRow = row ~/ 3 * 3;
    final boxCol = col ~/ 3 * 3;
    final box = <Cell>[];

    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        box.add(cells[boxRow + i][boxCol + j]);
      }
    }
    return box;
  }

  // 특정 기물의 이동 가능한 셀들 가져오기
  List<Cell> getPieceMovableCells(int row, int col) {
    final cell = getCell(row, col);
    if (cell.piece == null) return [];

    switch (cell.piece!) {
      case ChessPiece.knight:
        return _getKnightMovableCells(row, col);
      case ChessPiece.bishop:
        return _getBishopMovableCells(row, col);
      case ChessPiece.rook:
        return _getRookMovableCells(row, col);
      case ChessPiece.king:
        return _getKingMovableCells(row, col);
    }
  }

  // 나이트 이동 가능 셀
  List<Cell> _getKnightMovableCells(int row, int col) {
    final moves = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1],
    ];
    return _getValidCellsFromMoves(row, col, moves);
  }

  // 비숍 이동 가능 셀
  List<Cell> _getBishopMovableCells(int row, int col) {
    final cells = <Cell>[];
    final directions = [
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1],
    ];

    for (final dir in directions) {
      var currentRow = row + dir[0];
      var currentCol = col + dir[1];

      while (_isValidPosition(currentRow, currentCol)) {
        final currentCell = getCell(currentRow, currentCol);
        if (currentCell.piece != null) break;
        cells.add(currentCell);
        currentRow += dir[0];
        currentCol += dir[1];
      }
    }
    return cells;
  }

  // 룩 이동 가능 셀
  List<Cell> _getRookMovableCells(int row, int col) {
    final cells = <Cell>[];
    final directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];

    for (final dir in directions) {
      var currentRow = row + dir[0];
      var currentCol = col + dir[1];

      while (_isValidPosition(currentRow, currentCol)) {
        final currentCell = getCell(currentRow, currentCol);
        if (currentCell.piece != null) break;
        cells.add(currentCell);
        currentRow += dir[0];
        currentCol += dir[1];
      }
    }
    return cells;
  }

  // 킹 이동 가능 셀
  List<Cell> _getKingMovableCells(int row, int col) {
    final moves = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];
    return _getValidCellsFromMoves(row, col, moves);
  }

  // 주어진 이동 패턴에 따른 유효한 셀들 반환
  List<Cell> _getValidCellsFromMoves(int row, int col, List<List<int>> moves) {
    final cells = <Cell>[];

    for (final move in moves) {
      final newRow = row + move[0];
      final newCol = col + move[1];

      if (_isValidPosition(newRow, newCol)) {
        final cell = getCell(newRow, newCol);
        if (cell.piece == null) {
          cells.add(cell);
        }
      }
    }
    return cells;
  }

  // 위치가 보드 내에 있는지 확인
  bool _isValidPosition(int row, int col) {
    return row >= 0 && row < size && col >= 0 && col < size;
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'cells':
          cells
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
    };
  }

  // JSON 역직렬화
  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      cells:
          (json['cells'] as List)
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
    );
  }

  // 복사본 생성
  Board copyWith({List<List<Cell>>? cells}) {
    return Board(cells: cells ?? this.cells);
  }

  @override
  List<Object?> get props => [cells];
}
