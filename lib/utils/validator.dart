import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/models/cell.dart';

class Validator {
  final Board board;

  Validator(this.board);

  // 특정 위치의 셀이 유효한지 검사
  bool isCellValid(int row, int col) {
    final cell = board.getCell(row, col);
    if (cell.number == null || cell.isInitial) return true;

    // 행 검사
    if (_hasDuplicateInRow(row, col)) return false;

    // 열 검사
    if (_hasDuplicateInColumn(row, col)) return false;

    // 3x3 박스 검사
    if (_hasDuplicateInBox(row, col)) return false;

    // 해당 셀이 체스 기물의 이동 범위에 있는 경우 검사
    return !_hasConflictWithChessPieces(row, col);
  }

  // 행에서 중복 검사
  bool _hasDuplicateInRow(int row, int col) {
    final currentCell = board.getCell(row, col);
    final rowCells = board.getRow(row);

    return _hasDuplicates(rowCells, currentCell.number!, exclude: currentCell);
  }

  // 열에서 중복 검사
  bool _hasDuplicateInColumn(int row, int col) {
    final currentCell = board.getCell(row, col);
    final columnCells = board.getColumn(col);

    return _hasDuplicates(columnCells, currentCell.number!, exclude: currentCell);
  }

  // 3x3 박스에서 중복 검사
  bool _hasDuplicateInBox(int row, int col) {
    final currentCell = board.getCell(row, col);
    final boxCells = board.getBox(row, col);

    return _hasDuplicates(boxCells, currentCell.number!, exclude: currentCell);
  }

  // 체스 기물과의 충돌 검사
  bool _hasConflictWithChessPieces(int row, int col) {
    final currentCell = board.getCell(row, col);

    // 보드의 모든 체스 기물 검사
    for (var i = 0; i < Board.size; i++) {
      for (var j = 0; j < Board.size; j++) {
        final cell = board.getCell(i, j);
        if (cell.piece == null) continue;

        // 해당 기물의 이동 가능한 셀들 가져오기
        final movableCells = board.getPieceMovableCells(i, j);

        // 현재 검사 중인 셀이 이동 가능한 범위에 있는지 확인
        bool isInRange = movableCells.any((moveCell) => identical(moveCell, currentCell));

        if (!isInRange) continue;

        // 이동 가능한 셀들 중 중복된 숫자가 있는지 검사
        final numbers = <int>{};
        for (var moveCell in movableCells) {
          if (moveCell.number == null || moveCell.isInitial) continue;
          if (identical(moveCell, currentCell)) {
            if (numbers.contains(currentCell.number)) return true;
            numbers.add(currentCell.number!);
          } else {
            if (moveCell.number != null) {
              if (numbers.contains(moveCell.number)) return true;
              numbers.add(moveCell.number!);
            }
          }
        }
      }
    }
    return false;
  }

  // 리스트 내 중복 검사 (현재 셀 제외)
  bool _hasDuplicates(List<Cell> cells, int number, {required Cell exclude}) {
    return cells.where((cell) => !identical(cell, exclude) && !cell.isInitial && cell.number == number).isNotEmpty;
  }
}
