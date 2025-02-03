import 'package:flutter/material.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/enums/cell_type.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState;
  Set<String> _highlightedCells = {};

  GameProvider(this._gameState);

  // Getters
  GameState get gameState => _gameState;
  bool get hasSelectedCell => _gameState.hasSelectedCell;
  List<int> get selectedCell => _gameState.selectedCell;
  Board get currentBoard => _gameState.currentBoard;

  // 선택된 셀이 체스 기물을 포함하고 있는지 확인
  bool get selectedCellHasPiece {
    if (!hasSelectedCell) return false;
    final cell = currentBoard.getCell(selectedCell[0], selectedCell[1]);
    return cell.piece != null;
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

    final newCell = Cell(type: CellType.filled, number: number, isInitial: false);

    final newBoard = currentBoard.updateCell(row, col, newCell);
    _updateGameState(_gameState.copyWith(currentBoard: newBoard));

    notifyListeners();
  }

  // 셀이 하이라이트되어야 하는지 확인
  bool isCellHighlighted(int row, int col) {
    return _highlightedCells.contains('$row,$col');
  }

  // 셀이 선택되어 있는지 확인
  bool isCellSelected(int row, int col) {
    return selectedCell[0] == row && selectedCell[1] == col;
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
      // 이동 가능한 셀들의 좌표를 찾아서 하이라이트에 추가
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
      // 일반 셀의 경우 같은 행, 열 하이라이트
      for (var i = 0; i < 9; i++) {
        // 같은 행의 모든 셀
        _highlightedCells.add('$row,$i');
        // 같은 열의 모든 셀
        _highlightedCells.add('$i,$col');
        // 같은 3x3 박스 내의 모든 셀
        final boxStartRow = (row ~/ 3) * 3;
        final boxStartCol = (col ~/ 3) * 3;
        for (var r = boxStartRow; r < boxStartRow + 3; r++) {
          for (var c = boxStartCol; c < boxStartCol + 3; c++) {
            _highlightedCells.add('$r,$c');
          }
        }
      }
    }
  }

  void _clearHighlightedCells() {
    _highlightedCells.clear();
  }
}
