import 'dart:async';

import 'package:chessudoku/enums/cell_type.dart';
import 'package:chessudoku/enums/game_status.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:chessudoku/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProvider extends ChangeNotifier {
  GameState? _gameState;
  final StorageService _storage;
  bool _isLoading = false;
  String? _errorMessage;

  GameProvider(this._storage);

  // Getters
  GameState? get gameState => _gameState;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSelectedCell => _gameState?.hasSelectedCell ?? false;

  // 게임 초기화
  Future<void> initializeGame(String puzzleId, Board initialBoard, Board solutionBoard) async {
    _setLoading(true);
    try {
      // 초기 보드의 셀 타입을 적절히 설정
      final processedInitialBoard = Board(
        cells:
            initialBoard.cells
                .map(
                  (row) =>
                      row.map((cell) {
                        if (cell.piece != null) {
                          return cell.copyWith(type: CellType.piece);
                        } else if (cell.number != null) {
                          return cell.copyWith(type: CellType.initial);
                        } else {
                          return cell.copyWith(type: CellType.empty);
                        }
                      }).toList(),
                )
                .toList(),
      );

      final newGameState = GameState(
        puzzleId: puzzleId,
        status: GameStatus.playing,
        initialBoard: processedInitialBoard,
        currentBoard: processedInitialBoard,
        solutionBoard: solutionBoard,
        startTime: DateTime.now(),
      );

      _gameState = newGameState;
      await _storage.saveGameProgress(newGameState);
      _setError(null);
    } catch (e) {
      _setError('Failed to initialize game: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 셀 선택
  void selectCell(int row, int col) {
    if (_gameState == null) return;

    final cell = _gameState!.currentBoard.getCell(row, col);
    // piece나 initial 타입의 셀은 선택 불가
    if (cell.type == CellType.piece || cell.type == CellType.initial) return;

    _gameState = _gameState!.copyWith(selectedCell: [row, col]);
    notifyListeners();
  }

  // 숫자 입력
  Future<void> enterNumber(int number) async {
    if (_gameState == null || !hasSelectedCell) return;

    final [row, col] = _gameState!.selectedCell;
    final cell = _gameState!.currentBoard.getCell(row, col);

    // piece나 initial 타입의 셀은 수정 불가
    if (cell.type == CellType.piece || cell.type == CellType.initial) return;

    // 유효성 검사
    if (!_isValidMove(row, col, number)) {
      _setError('Invalid move');
      return;
    }

    final newCell = cell.copyWith(
      number: number,
      type: CellType.filled, // 플레이어가 입력한 숫자는 filled 타입
    );
    final newBoard = _gameState!.currentBoard.updateCell(row, col, newCell);

    // 게임 완료 체크
    final isCompleted = _checkCompletion(newBoard);
    final newStatus = isCompleted ? GameStatus.completed : GameStatus.playing;

    _gameState = _gameState!.copyWith(
      currentBoard: newBoard,
      status: newStatus,
      selectedCell: [-1, -1], // 선택 해제
    );

    await _storage.saveGameProgress(_gameState!);
    notifyListeners();
  }

  // 숫자 삭제
  Future<void> clearNumber() async {
    if (_gameState == null || !hasSelectedCell) return;

    final [row, col] = _gameState!.selectedCell;
    final cell = _gameState!.currentBoard.getCell(row, col);

    // piece나 initial 타입의 셀은 수정 불가
    if (cell.type == CellType.piece || cell.type == CellType.initial) return;

    final newCell = cell.copyWith(
      number: null,
      type: CellType.empty, // 숫자를 지우면 empty 타입으로 변경
    );
    final newBoard = _gameState!.currentBoard.updateCell(row, col, newCell);

    _gameState = _gameState!.copyWith(currentBoard: newBoard, selectedCell: [-1, -1]);

    await _storage.saveGameProgress(_gameState!);
    notifyListeners();
  }

  // 현재 보드 상태 검사
  Future<List<List<bool>>> checkCurrentBoard() async {
    if (_gameState == null) return [];

    final currentBoard = _gameState!.currentBoard;
    final solutionBoard = _gameState!.solutionBoard;
    var incorrectCells = List.generate(Board.size, (_) => List.filled(Board.size, false));

    // 모든 셀 검사
    for (var i = 0; i < Board.size; i++) {
      for (var j = 0; j < Board.size; j++) {
        final currentCell = currentBoard.getCell(i, j);
        final solutionCell = solutionBoard.getCell(i, j);

        // 체스 기물이 있거나 아직 입력되지 않은 셀은 건너뜀
        if (currentCell.type == CellType.piece || currentCell.type == CellType.empty) continue;

        // 현재 값이 정답과 다르면 표시
        if (currentCell.number != solutionCell.number) {
          incorrectCells[i][j] = true;
        }
      }
    }

    return incorrectCells;
  }

  // 유효성 검사 메서드들...
  bool _isValidMove(int row, int col, int number) {
    if (_gameState == null) return false;

    final board = _gameState!.currentBoard;

    // 행 검사
    if (!_isValidInRow(board, row, number)) return false;

    // 열 검사
    if (!_isValidInColumn(board, col, number)) return false;

    // 3x3 박스 검사
    if (!_isValidInBox(board, row, col, number)) return false;

    // 체스 기물 규칙 검사
    if (!_isValidForChessPieces(board, row, col, number)) return false;

    return true;
  }

  // 행 유효성 검사
  bool _isValidInRow(Board board, int row, int number) {
    final rowCells = board.getRow(row);
    return !rowCells.any((cell) => cell.number == number);
  }

  // 열 유효성 검사
  bool _isValidInColumn(Board board, int col, int number) {
    final colCells = board.getColumn(col);
    return !colCells.any((cell) => cell.number == number);
  }

  // 3x3 박스 유효성 검사
  bool _isValidInBox(Board board, int row, int col, int number) {
    final boxCells = board.getBox(row, col);
    return !boxCells.any((cell) => cell.number == number);
  }

  // 체스 기물 규칙 검사
  bool _isValidForChessPieces(Board board, int row, int col, int number) {
    // 모든 기물의 영향권에 있는 셀들 검사
    for (var i = 0; i < Board.size; i++) {
      for (var j = 0; j < Board.size; j++) {
        final cell = board.getCell(i, j);
        if (cell.type != CellType.piece) continue;

        final affectedCells = board.getPieceMovableCells(i, j);
        if (!affectedCells.contains(board.getCell(row, col))) continue;

        // 기물의 영향권 내에 같은 숫자가 있는지 검사
        for (final affectedCell in affectedCells) {
          if (affectedCell.number == number) return false;
        }
      }
    }
    return true;
  }

  // 게임 완료 체크
  bool _checkCompletion(Board board) {
    // 모든 빈 칸이 채워졌는지 확인
    for (var i = 0; i < Board.size; i++) {
      for (var j = 0; j < Board.size; j++) {
        final cell = board.getCell(i, j);
        if (cell.type == CellType.empty) return false;
      }
    }
    return true;
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 메시지 설정
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
