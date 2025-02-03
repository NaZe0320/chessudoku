import 'package:flutter/material.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/enums/cell_type.dart';

class GameProvider extends ChangeNotifier {
  final BuildContext _context;
  GameState _gameState;
  Set<String> _highlightedCells = {};
  Set<String> _wrongCells = {};

  GameProvider(this._gameState, this._context);

  // Getters
  GameState get gameState => _gameState;
  bool get hasSelectedCell => _gameState.hasSelectedCell;
  List<int> get selectedCell => _gameState.selectedCell;
  Board get currentBoard => _gameState.currentBoard;

  // 셀이 잘못 입력되었는지 확인
  bool isCellWrong(int row, int col) {
    return _wrongCells.contains('$row,$col');
  }

  // 선택된 셀이 체스 기물을 포함하고 있는지 확인
  bool get selectedCellHasPiece {
    if (!hasSelectedCell) return false;
    final cell = currentBoard.getCell(selectedCell[0], selectedCell[1]);
    return cell.piece != null;
  }

  // 셀이 하이라이트되어야 하는지 확인
  bool isCellHighlighted(int row, int col) {
    return _highlightedCells.contains('$row,$col');
  }

  // 셀이 선택되어 있는지 확인
  bool isCellSelected(int row, int col) {
    return selectedCell[0] == row && selectedCell[1] == col;
  }

  // 셀 선택
  void selectCell(int row, int col) {
    final cell = currentBoard.getCell(row, col);

    // 이미 선택된 셀을 다시 선택하면 선택 해제
    if (_gameState.selectedCell[0] == row && _gameState.selectedCell[1] == col) {
      _updateSelectedCell(-1, -1);
      _clearHighlightedCells();
    } else {
      _updateSelectedCell(row, col);
      _updateHighlightedCells(row, col, cell);
    }

    notifyListeners();
  }

  // 숫자 입력
  void inputNumber(int number) {
    if (!hasSelectedCell) return;

    final row = selectedCell[0];
    final col = selectedCell[1];
    final cell = currentBoard.getCell(row, col);

    // 초기값이나 체스 기물이 있는 셀은 수정 불가
    if (cell.isInitial || cell.piece != null) return;

    // 같은 숫자를 다시 누르면 지우기
    if (cell.number == number) {
      clearCell();
      return;
    }

    final newCell = Cell(type: CellType.filled, number: number);
    final newBoard = currentBoard.updateCell(row, col, newCell);
    _updateGameState(_gameState.copyWith(currentBoard: newBoard));

    // 잘못된 입력 표시 초기화
    _wrongCells.remove('$row,$col');

    notifyListeners();
  }

  // 선택된 셀의 값을 지우기
  void clearCell() {
    if (!hasSelectedCell) return;

    final row = selectedCell[0];
    final col = selectedCell[1];
    final cell = currentBoard.getCell(row, col);

    // 초기값이나 체스 기물이 있는 셀은 수정 불가
    if (cell.isInitial || cell.piece != null) return;

    final newCell = Cell(type: CellType.empty);
    final newBoard = currentBoard.updateCell(row, col, newCell);
    _updateGameState(_gameState.copyWith(currentBoard: newBoard));

    // 입력된 셀과 관련된 모든 셀들의 유효성 다시 검사
    _validateRelatedCells(row, col);

    notifyListeners();
  }

  // 현재 입력된 숫자들의 유효성 검사
  void checkCurrentInput() {
    _wrongCells.clear();
    bool hasError = false;

    // 스도쿠 규칙 검사 (행, 열, 3x3 박스)
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        final cell = currentBoard.getCell(i, j);
        if (cell.number == null) continue;

        // 행 검사
        final row = currentBoard.getRow(i);
        if (_hasDuplicateInList(row, i, j)) {
          _wrongCells.add('$i,$j');
          hasError = true;
        }

        // 열 검사
        final column = currentBoard.getColumn(j);
        if (_hasDuplicateInList(column, i, j)) {
          _wrongCells.add('$i,$j');
          hasError = true;
        }

        // 3x3 박스 검사
        final box = currentBoard.getBox(i, j);
        if (_hasDuplicateInBox(box, i, j)) {
          _wrongCells.add('$i,$j');
          hasError = true;
        }

        // 체스 규칙 검사
        if (cell.piece != null) {
          final movableCells = currentBoard.getPieceMovableCells(i, j);
          if (_hasConflictWithPieceRule(cell, movableCells, i, j)) {
            _wrongCells.add('$i,$j');
            hasError = true;
          }
        }
      }
    }

    if (!hasError) {
      ScaffoldMessenger.of(
        _context,
      ).showSnackBar(const SnackBar(content: Text('현재까지 입력이 모두 올바릅니다!'), duration: Duration(seconds: 2)));
    }

    notifyListeners();
  }

  // 내부 상태 업데이트 메서드들
  void _updateGameState(GameState newState) {
    _gameState = newState;
  }

  void _updateSelectedCell(int row, int col) {
    _gameState = _gameState.copyWith(selectedCell: [row, col]);
  }

  void _updateHighlightedCells(int row, int col, Cell cell) {
    _highlightedCells.clear();

    if (cell.piece != null) {
      // 체스 기물의 경우 이동 가능한 셀만 하이라이트
      final movableCells = currentBoard.getPieceMovableCells(row, col);
      for (var i = 0; i < 9; i++) {
        for (var j = 0; j < 9; j++) {
          final currentCell = currentBoard.getCell(i, j);
          for (var movableCell in movableCells) {
            if (identical(currentCell, movableCell)) {
              _highlightedCells.add('$i,$j');
              break;
            }
          }
        }
      }
    } else {
      // 일반 셀의 경우 같은 행, 열, 3x3 박스 하이라이트
      for (var i = 0; i < 9; i++) {
        _highlightedCells.add('$row,$i'); // 같은 행
        _highlightedCells.add('$i,$col'); // 같은 열
      }

      // 같은 3x3 박스
      final boxStartRow = (row ~/ 3) * 3;
      final boxStartCol = (col ~/ 3) * 3;
      for (var r = boxStartRow; r < boxStartRow + 3; r++) {
        for (var c = boxStartCol; c < boxStartCol + 3; c++) {
          _highlightedCells.add('$r,$c');
        }
      }
    }
  }

  void _clearHighlightedCells() {
    _highlightedCells.clear();
  }

  // 리스트 내 중복 숫자 검사
  bool _hasDuplicateInList(List<Cell> cells, int currentRow, int currentCol) {
    final currentNumber = currentBoard.getCell(currentRow, currentCol).number;
    if (currentNumber == null) return false;

    var count = 0;
    for (var cell in cells) {
      if (cell.number == currentNumber) count++;
      if (count > 1) return true;
    }
    return false;
  }

  // 3x3 박스 내 중복 숫자 검사
  bool _hasDuplicateInBox(List<Cell> boxCells, int currentRow, int currentCol) {
    final currentNumber = currentBoard.getCell(currentRow, currentCol).number;
    if (currentNumber == null) return false;

    var count = 0;
    for (var cell in boxCells) {
      if (cell.number == currentNumber) count++;
      if (count > 1) return true;
    }
    return false;
  }

  // 체스 규칙 위반 검사
  bool _hasConflictWithPieceRule(Cell currentCell, List<Cell> movableCells, int row, int col) {
    final numbers = <int>{};
    for (var cell in movableCells) {
      if (cell.number != null) {
        if (numbers.contains(cell.number)) {
          return true; // 이동 가능한 셀들 중에 중복된 숫자가 있음
        }
        numbers.add(cell.number!);
      }
    }
    return false;
  }

  // 입력된 셀과 관련된 모든 셀들의 유효성 검사
  void _validateRelatedCells(int inputRow, int inputCol) {
    // 영향을 받는 모든 셀의 wrong 상태 초기화
    _wrongCells.clear();

    // 같은 행에 있는 모든 셀 검사
    final row = currentBoard.getRow(inputRow);
    for (var col = 0; col < 9; col++) {
      if (_hasDuplicateInList(row, inputRow, col)) {
        _wrongCells.add('$inputRow,$col');
      }
    }

    // 같은 열에 있는 모든 셀 검사
    final column = currentBoard.getColumn(inputCol);
    for (var row = 0; row < 9; row++) {
      if (_hasDuplicateInList(column, row, inputCol)) {
        _wrongCells.add('$row,$inputCol');
      }
    }

    // 같은 3x3 박스에 있는 모든 셀 검사
    final boxStartRow = (inputRow ~/ 3) * 3;
    final boxStartCol = (inputCol ~/ 3) * 3;
    final box = currentBoard.getBox(inputRow, inputCol);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final currentRow = boxStartRow + r;
        final currentCol = boxStartCol + c;
        if (_hasDuplicateInBox(box, currentRow, currentCol)) {
          _wrongCells.add('$currentRow,$currentCol');
        }
      }
    }

    // 체스 기물이 있는 셀들과 그 이동 범위 검사
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        final cell = currentBoard.getCell(row, col);
        if (cell.piece != null) {
          final movableCells = currentBoard.getPieceMovableCells(row, col);
          if (_hasConflictWithPieceRule(cell, movableCells, row, col)) {
            _wrongCells.add('$row,$col');
          }
        }
      }
    }
  }
}
