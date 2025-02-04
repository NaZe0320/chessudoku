import 'dart:async';

import 'package:chessudoku/enums/game_status.dart';
import 'package:chessudoku/models/move.dart';
import 'package:chessudoku/models/move_history.dart';
import 'package:chessudoku/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/enums/cell_type.dart';

class GameProvider extends ChangeNotifier {
  final BuildContext _context;
  GameState _gameState;
  final StorageService _storageService;
  final Set<String> _highlightedCells = {};
  final Set<String> _wrongCells = {};

  Timer? _timer;
  DateTime? _startTime;
  // 사용자가 수동으로 일시정지했는지 여부
  DateTime? _pauseTime;
  // 앱이 백그라운드로 갔는지 여부
  bool _isBackgrounded = false;
  int _accumulatedSeconds = 0;
  bool _isMemoMode = false;

  GameProvider(this._gameState, this._context, this._storageService) {
    _accumulatedSeconds = _gameState.elapsedSeconds;
    startTimer();
  }

  // Getters
  GameState get gameState => _gameState;
  bool get hasSelectedCell => _gameState.hasSelectedCell;
  List<int> get selectedCell => _gameState.selectedCell;
  Board get currentBoard => _gameState.currentBoard;
  bool get isPaused => _pauseTime != null;
  bool get isMemoMode => _isMemoMode;
  bool get canUndo => _gameState.canUndo;

  // 게임 상태 저장
  Future<void> saveGameProgress() async {
    try {
      await _storageService.saveGameProgress(_gameState);
    } catch (e) {
      print('Error saving game progress: $e');
    }
  }

  /// ----------------------------------------- 타이머 -------------------------------------------

  // 타이머 일시정지 (사용자 수동)
  void pauseTimer() {
    if (_pauseTime != null) return;
    _stopTimer();
    _pauseTime = DateTime.now();
    notifyListeners();
  }

  // 타이머 재개 (사용자 수동)
  void resumeTimer() {
    if (_pauseTime == null) return;
    _accumulatedSeconds += DateTime.now().difference(_pauseTime!).inSeconds;
    _pauseTime = null;
    startTimer();
    notifyListeners();
  }

  // 앱이 백그라운드로 갈 때
  void onBackground() {
    if (_isBackgrounded) return;
    _isBackgrounded = true;
    _stopTimer();
  }

  // 앱이 포그라운드로 돌아올 때
  void onForeground() {
    if (!_isBackgrounded) return;
    _isBackgrounded = false;
    if (!isPaused) {
      // 사용자가 수동으로 일시정지하지 않은 경우에만 재개
      startTimer();
    }
  }

  // 타이머 중지 로직 (공통)
  void _stopTimer() {
    _timer?.cancel();
    if (_startTime != null) {
      final now = DateTime.now();
      _accumulatedSeconds += now.difference(_startTime!).inSeconds;
      _startTime = null;
      saveGameProgress();
    }
  }

  void startTimer() {
    if (_isBackgrounded || isPaused) return; // 백그라운드 상태나 일시정지 상태면 시작하지 않음

    _startTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final currentElapsed = _accumulatedSeconds + DateTime.now().difference(_startTime!).inSeconds;
        _updateGameState(_gameState.copyWith(elapsedSeconds: currentElapsed));
        notifyListeners();
      }
    });
  }

  // 게임 종료
  void completeGame() async {
    _timer?.cancel();
    _updateGameState(
      _gameState.copyWith(
        status: GameStatus.completed,
        elapsedSeconds: _gameState.elapsedSeconds,
        moveHistory: const MoveHistory(), // 게임 완료시 히스토리 초기화
      ),
    );

    // 게임 완료 시 저장된 게임 상태 삭제
    await _storageService.clearGameProgress();

    // 완료 메시지 표시
    if (_context.mounted) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Congratulations! You completed the puzzle!'), duration: Duration(seconds: 3)),
      );
    }
  }

  // Provider dispose 시 타이머 정리
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 경과 시간을 문자열로 변환하는 유틸리티 메서드
  String get formattedTime {
    final seconds = _gameState.elapsedSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// ----------------------------------------- 셀 입력 ------------------------------------------

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

    if (_isMemoMode) {
      // 메모 모드일 때는 메모 추가/제거
      final currentMemos = Set<int>.from(cell.memos);
      if (currentMemos.contains(number)) {
        currentMemos.remove(number);
      } else {
        currentMemos.add(number);
      }

      final newCell = cell.copyWith(memos: currentMemos);
      final newBoard = currentBoard.updateCell(row, col, newCell);
      _updateGameState(_gameState.copyWith(currentBoard: newBoard));
    } else {
      // 일반 모드일 때는 숫자 입력
      if (cell.number == number) {
        clearCell();
        return;
      }

      final newCell = Cell(type: CellType.filled, number: number);
      final newBoard = currentBoard.updateCell(row, col, newCell);
      _updateGameState(_gameState.copyWith(currentBoard: newBoard));

      _wrongCells.remove('$row,$col');

      if (_isGameComplete()) {
        completeGame();
      }
    }

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

  bool _isGameComplete() {
    // 스도쿠 보드의 모든 셀을 검사
    for (var i = 0; i < Board.size; i++) {
      for (var j = 0; j < Board.size; j++) {
        final cell = currentBoard.getCell(i, j);

        // 비어있는 셀이 있으면 완료되지 않은 상태
        if (cell.type == CellType.empty) {
          return false;
        }

        // 체스 기물이 없고 숫자가 없는 셀이 있으면 완료되지 않은 상태
        if (cell.piece == null && cell.number == null) {
          return false;
        }
      }
    }

    // 현재 입력된 숫자들의 유효성 검사
    checkCurrentInput();

    // 잘못된 입력(wrongCells)이 있으면 완료되지 않은 상태
    if (_wrongCells.isNotEmpty) {
      return false;
    }

    // 모든 검사를 통과하면 게임 완료
    return true;
  }

  /// ----------------------------------------- 메모 기능 ------------------------------------------

  // 메모 모드 토글
  void toggleMemoMode() {
    _isMemoMode = !_isMemoMode;
    notifyListeners();
  }

  /// ----------------------------------------- 되돌리기 기능 ------------------------------------------

  void _addMove(int row, int col, Cell previousCell, Cell newCell) {
    final move = Move(row: row, col: col, previousCell: previousCell, newCell: newCell);

    final newHistory = MoveHistory(moves: List.from(_gameState.moveHistory.moves)..add(move));

    _updateGameState(_gameState.copyWith(moveHistory: newHistory));
  }

  void undo() {
    final currentHistory = _gameState.moveHistory;
    final lastMove = currentHistory.undo();
    if (lastMove == null) return;

    final newBoard = currentBoard.updateCell(lastMove.row, lastMove.col, lastMove.previousCell);

    // 새로운 MoveHistory 생성 (마지막 move가 제거된 상태)
    final newHistory = MoveHistory(moves: List.from(currentHistory.moves));

    _updateGameState(_gameState.copyWith(currentBoard: newBoard, moveHistory: newHistory));

    // 입력된 셀과 관련된 모든 셀들의 유효성 다시 검사
    _validateRelatedCells(lastMove.row, lastMove.col);

    notifyListeners();
  }
}
