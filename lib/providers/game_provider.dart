import 'dart:async';

import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/enums/game_status.dart';
import 'package:chessudoku/models/game_record.dart';
import 'package:chessudoku/models/move.dart';
import 'package:chessudoku/models/move_history.dart';
import 'package:chessudoku/providers/ad_provider.dart';
import 'package:chessudoku/providers/authentication_provider.dart';
import 'package:chessudoku/services/storage_service.dart';
import 'package:chessudoku/widgets/dialogs/check_recharge_dialog.dart';
import 'package:chessudoku/widgets/dialogs/completion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/enums/cell_type.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

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
  bool get canCheck => _gameState.remainingChecks > 0;
  int get remainingChecks => _gameState.remainingChecks;

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

  // 타이머 시작
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

  // 게임 완료 시 기록 저장
  Future<void> _saveGameRecord() async {
    // AuthProvider에서 현재 사용자 ID 가져오기
    final userId = Provider.of<AuthProvider>(_context, listen: false).user?.uid;
    if (userId == null) {
      print('Cannot save record: No user logged in');
      return;
    }

    final record = GameRecord(
      difficulty: _gameState.difficulty,
      elapsedSeconds: _gameState.elapsedSeconds,
      completedAt: DateTime.now(),
      hintsUsed: _gameState.hintsUsed,
      puzzleId: _gameState.puzzleId,
    );

    try {
      await _storageService.saveGameRecord(record, userId);
      print("Saving Game Record Success");
    } catch (e) {
      if (_context.mounted) {
        ScaffoldMessenger.of(_context).showSnackBar(SnackBar(content: Text('Failed to save record: ${e.toString()}')));
      }
      print('Error saving game record: $e');
    }
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

    // 게임 기록 저장
    await _saveGameRecord();

    // 게임 완료 시 저장된 게임 상태 삭제
    await _storageService.clearGameProgress();

    if (_context.mounted) {
      // 완료 다이얼로그 표시
      await showDialog(
        context: _context,
        barrierDismissible: false,
        builder:
            (context) => CompletionDialog(
              elapsedSeconds: _gameState.elapsedSeconds,
              hintsUsed: _gameState.hintsUsed,
              difficulty: _gameState.difficulty,
            ),
      );

      // 다이얼로그가 닫히면 게임 화면을 닫고 홈으로 돌아가기
      if (_context.mounted) {
        Navigator.of(_context).pop(); // 게임 화면 닫기
      }
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
      _addMove(row, col, cell, newCell);
      final newBoard = currentBoard.updateCell(row, col, newCell);
      _updateGameState(_gameState.copyWith(currentBoard: newBoard));

      _wrongCells.clear();

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
    _addMove(row, col, cell, newCell);
    final newBoard = currentBoard.updateCell(row, col, newCell);
    _updateGameState(_gameState.copyWith(currentBoard: newBoard));

    _wrongCells.clear();

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

  // ----------------------------------- 유효성 검사 ----------------------------------

  // 현재 입력된 숫자들의 유효성 검사
  void checkCurrentInput() {
    if (!canCheck) {
      _showCheckRechargeDialog();
      return;
    }

    _wrongCells.clear();

    _updateGameState(_gameState.copyWith(hintsUsed: _gameState.hintsUsed + 1));

    _updateGameState(_gameState.copyWith(remainingChecks: _gameState.remainingChecks - 1));

    final isValid = _validateBoardAndMarkCells();

    if (isValid) {
      ScaffoldMessenger.of(
        _context,
      ).showSnackBar(const SnackBar(content: Text('All inputs are correct!'), duration: Duration(seconds: 2)));
    }

    notifyListeners();
  }

  // 체크 기능 충전을 위한 광고 다이얼로그 표시
  void _showCheckRechargeDialog() {
    showDialog(context: _context, builder: (context) => CheckRechargeDialog(onWatchAd: _rechargeChecksWithAd));
  }

  // 광고를 통한 체크 기능 충전
  Future<void> _rechargeChecksWithAd() async {
    try {
      final adProvider = Provider.of<AdProvider>(_context, listen: false);
      final success = await adProvider.showRewardedAd();

      if (success) {
        _updateGameState(_gameState.copyWith(remainingChecks: GameState.maxChecks));
        notifyListeners();

        if (_context.mounted) {
          ScaffoldMessenger.of(_context).showSnackBar(const SnackBar(content: Text('Checks recharged successfully!')));
        }
      }
    } catch (e) {
      if (_context.mounted) {
        ScaffoldMessenger.of(
          _context,
        ).showSnackBar(const SnackBar(content: Text('Failed to recharge checks. Please try again.')));
      }
    }
  }

  // 현재 보드의 유효성을 검사하고 잘못된 셀을 표시
  bool _validateBoardAndMarkCells() {
    _wrongCells.clear();
    bool hasError = false;

    // 스도쿠 기본 규칙 검사 (행, 열, 3x3 박스)
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        final cell = currentBoard.getCell(i, j);
        if (cell.number == null) continue;

        // 행 검사
        if (_hasDuplicateInRow(i, j)) {
          _wrongCells.add('$i,$j');
          hasError = true;
        }

        // 열 검사
        if (_hasDuplicateInColumn(i, j)) {
          _wrongCells.add('$i,$j');
          hasError = true;
        }

        // 3x3 박스 검사
        if (_hasDuplicateInBox(i, j)) {
          _wrongCells.add('$i,$j');
          hasError = true;
        }
      }
    }

    // 체스 기물 규칙 검사
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        final cell = currentBoard.getCell(i, j);
        if (cell.piece != null) {
          if (_hasChessPieceConflict(i, j)) {
            _wrongCells.add('$i,$j');
            hasError = true;
          }
        }
      }
    }

    return !hasError;
  }

  // 보드의 유효성만 검사 (wrongCells 표시하지 않음)
  bool _validateBoardOnly() {
    // 스도쿠 기본 규칙 검사 (행, 열, 3x3 박스)
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        final cell = currentBoard.getCell(i, j);
        if (cell.number == null) continue;

        // 행 검사
        if (_hasDuplicateInRow(i, j)) {
          return false;
        }

        // 열 검사
        if (_hasDuplicateInColumn(i, j)) {
          return false;
        }

        // 3x3 박스 검사
        if (_hasDuplicateInBox(i, j)) {
          return false;
        }
      }
    }

    // 체스 기물 규칙 검사
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        final cell = currentBoard.getCell(i, j);
        if (cell.piece != null) {
          if (_hasChessPieceConflict(i, j)) {
            return false;
          }
        }
      }
    }

    return true;
  }

  // 행에서 중복 검사
  bool _hasDuplicateInRow(int row, int col) {
    final currentNumber = currentBoard.getCell(row, col).number;
    if (currentNumber == null) return false;

    for (var c = 0; c < 9; c++) {
      if (c != col) {
        final cell = currentBoard.getCell(row, c);
        if (cell.number == currentNumber) {
          return true;
        }
      }
    }
    return false;
  }

  // 열에서 중복 검사
  bool _hasDuplicateInColumn(int row, int col) {
    final currentNumber = currentBoard.getCell(row, col).number;
    if (currentNumber == null) return false;

    for (var r = 0; r < 9; r++) {
      if (r != row) {
        final cell = currentBoard.getCell(r, col);
        if (cell.number == currentNumber) {
          return true;
        }
      }
    }
    return false;
  }

  // 3x3 박스에서 중복 검사
  bool _hasDuplicateInBox(int row, int col) {
    final currentNumber = currentBoard.getCell(row, col).number;
    if (currentNumber == null) return false;

    final boxStartRow = (row ~/ 3) * 3;
    final boxStartCol = (col ~/ 3) * 3;

    for (var r = boxStartRow; r < boxStartRow + 3; r++) {
      for (var c = boxStartCol; c < boxStartCol + 3; c++) {
        if (r != row || c != col) {
          final cell = currentBoard.getCell(r, c);
          if (cell.number == currentNumber) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // 체스 기물 규칙 검사
  bool _hasChessPieceConflict(int row, int col) {
    final cell = currentBoard.getCell(row, col);
    if (cell.piece == null) return false;

    bool hasConflict = false;

    // 대각선 방향이 독립적으로 처리되어야 하는 비숍
    if (cell.piece == ChessPiece.bishop) {
      final diagonals = _getBishopDiagonals(row, col);
      for (final diagonal in diagonals) {
        final numbers = <int>{};
        final conflictCells = <List<int>>[];

        for (final pos in diagonal) {
          final checkCell = currentBoard.getCell(pos[0], pos[1]);
          if (checkCell.piece != null) break; // 다른 기물이 있으면 해당 방향은 중단

          if (checkCell.number != null) {
            if (numbers.contains(checkCell.number)) {
              hasConflict = true;
              // 중복된 숫자를 가진 셀들을 모두 표시
              for (final conflictPos in conflictCells) {
                if (currentBoard.getCell(conflictPos[0], conflictPos[1]).number == checkCell.number) {
                  _wrongCells.add('${conflictPos[0]},${conflictPos[1]}');
                }
              }
              _wrongCells.add('${pos[0]},${pos[1]}');
            }
            numbers.add(checkCell.number!);
            conflictCells.add([pos[0], pos[1]]);
          }
        }
      }
      if (hasConflict) _wrongCells.add('$row,$col');
      return hasConflict;
    } else if (cell.piece == ChessPiece.rook) {
      final lines = _getRookLines(row, col);
      for (final line in lines) {
        final numbers = <int>{};
        final conflictCells = <List<int>>[];

        for (final pos in line) {
          final checkCell = currentBoard.getCell(pos[0], pos[1]);
          if (checkCell.piece != null) break; // 다른 기물이 있으면 해당 방향은 중단

          if (checkCell.number != null) {
            if (numbers.contains(checkCell.number)) {
              hasConflict = true;
              // 중복된 숫자를 가진 셀들을 모두 표시
              for (final conflictPos in conflictCells) {
                if (currentBoard.getCell(conflictPos[0], conflictPos[1]).number == checkCell.number) {
                  _wrongCells.add('${conflictPos[0]},${conflictPos[1]}');
                }
              }
              _wrongCells.add('${pos[0]},${pos[1]}');
            }
            numbers.add(checkCell.number!);
            conflictCells.add([pos[0], pos[1]]);
          }
        }
      }
      if (hasConflict) _wrongCells.add('$row,$col');
      return hasConflict;
    }

    // 나이트와 킹은 도달 가능한 모든 셀의 숫자가 서로 달라야 함
    final reachableCells = _getReachableCells(row, col, cell.piece!);
    final numbers = <int>{};
    final conflictCells = <List<int>>[];

    for (final pos in reachableCells) {
      final checkCell = currentBoard.getCell(pos[0], pos[1]);
      if (checkCell.piece != null) continue; // 다른 기물이 있는 칸은 무시

      if (checkCell.number != null) {
        if (numbers.contains(checkCell.number)) {
          hasConflict = true;
          // 중복된 숫자를 가진 셀들을 모두 표시
          for (final conflictPos in conflictCells) {
            if (currentBoard.getCell(conflictPos[0], conflictPos[1]).number == checkCell.number) {
              _wrongCells.add('${conflictPos[0]},${conflictPos[1]}');
            }
          }
          _wrongCells.add('${pos[0]},${pos[1]}');
        }
        numbers.add(checkCell.number!);
        conflictCells.add([pos[0], pos[1]]);
      }
    }

    if (hasConflict) _wrongCells.add('$row,$col');
    return hasConflict;
  }

  // 체스 기물이 도달할 수 있는 셀들의 좌표 반환
  List<List<int>> _getReachableCells(int row, int col, ChessPiece piece) {
    final cells = <List<int>>[];

    switch (piece) {
      case ChessPiece.knight:
        // 나이트의 L자 이동
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
        for (final move in moves) {
          final newRow = row + move[0];
          final newCol = col + move[1];
          if (_isValidPosition(newRow, newCol)) {
            cells.add([newRow, newCol]);
          }
        }
        break;

      case ChessPiece.king:
        // 킹의 8방향 1칸 이동
        for (var i = -1; i <= 1; i++) {
          for (var j = -1; j <= 1; j++) {
            if (i == 0 && j == 0) continue;
            final newRow = row + i;
            final newCol = col + j;
            if (_isValidPosition(newRow, newCol)) {
              cells.add([newRow, newCol]);
            }
          }
        }
        break;

      default:
        break;
    }

    return cells;
  }

  // 비숍의 4개 대각선 방향별 셀 좌표 반환
  List<List<List<int>>> _getBishopDiagonals(int row, int col) {
    final diagonals = <List<List<int>>>[];

    // 우상, 우하, 좌상, 좌하 방향
    final directions = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1],
    ];

    for (final dir in directions) {
      final diagonal = <List<int>>[];
      var r = row + dir[0];
      var c = col + dir[1];

      while (_isValidPosition(r, c)) {
        diagonal.add([r, c]);
        r += dir[0];
        c += dir[1];
      }

      if (diagonal.isNotEmpty) {
        diagonals.add(diagonal);
      }
    }

    return diagonals;
  }

  // 룩의 4개 직선 방향별 셀 좌표 반환 함수 추가
  List<List<List<int>>> _getRookLines(int row, int col) {
    final lines = <List<List<int>>>[];

    // 상, 하, 좌, 우 방향
    final directions = [
      [-1, 0], // 상
      [1, 0], // 하
      [0, -1], // 좌
      [0, 1], // 우
    ];

    for (final dir in directions) {
      final line = <List<int>>[];
      var r = row + dir[0];
      var c = col + dir[1];

      while (_isValidPosition(r, c)) {
        line.add([r, c]);
        r += dir[0];
        c += dir[1];
      }

      if (line.isNotEmpty) {
        lines.add(line);
      }
    }

    return lines;
  }

  // 좌표가 보드 범위 내인지 확인
  bool _isValidPosition(int row, int col) {
    return row >= 0 && row < 9 && col >= 0 && col < 9;
  }

  // 게임 완료 여부 확인
  bool _isGameComplete() {
    // 모든 셀이 채워져 있는지 확인
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        final cell = currentBoard.getCell(i, j);
        if (cell.piece == null && (cell.type == CellType.empty || cell.number == null)) {
          return false;
        }
      }
    }

    // 현재 입력의 유효성만 검사 (wrongCells 표시하지 않음)
    final isValid = _validateBoardOnly();

    if (!isValid) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(
          content: Text('There are some errors in your solution. Use check feature to find them.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return isValid;
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

    final currentMoves = List<Move>.from(_gameState.moveHistory.moves);
    currentMoves.add(move);
    final newHistory = MoveHistory(moves: currentMoves);

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

    notifyListeners();
  }

  //보드 초기화
  void resetBoard() {
    _wrongCells.clear();
    _highlightedCells.clear();
    _updateGameState(
      _gameState.copyWith(
        currentBoard: _gameState.initialBoard,
        selectedCell: [-1, -1],
        moveHistory: const MoveHistory(),
      ),
    );
    notifyListeners();
  }
}
