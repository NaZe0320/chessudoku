import 'package:flutter/foundation.dart';
import '../models/board.dart';
import '../services/game_service.dart';

/// 체스 스도쿠 게임의 상태를 관리하는 Provider
class GameProvider extends ChangeNotifier {
  final GameService _gameService;

  ChessSudokuPuzzle? _currentPuzzle;
  bool _isLoading = false;
  String _error = '';

  // 현재 보드의 상태 (사용자 입력 포함)
  ChessSudokuBoard? _currentBoard;

  // 선택된 셀의 위치
  int? selectedRow;
  int? selectedCol;

  // 힌트 사용 여부
  bool _showHints = false;

  int _mistakes = 0;
  int _hintsUsed = 0;
  Duration _elapsedTime = Duration.zero;

  GameProvider({GameService? gameService}) : _gameService = gameService ?? GameService();

  // Getters
  ChessSudokuPuzzle? get currentPuzzle => _currentPuzzle;
  ChessSudokuBoard? get currentBoard => _currentBoard;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get showHints => _showHints;
  int get mistakes => _mistakes;
  int get hintsUsed => _hintsUsed;
  bool get hasSelectedCell => selectedRow != null && selectedCol != null;
  Duration get elapsedTime => _elapsedTime;

  /// 새로운 퍼즐 생성
  Future<void> generatePuzzle({String difficulty = 'medium', List<PieceConfig>? pieceConfig}) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final puzzle = await _gameService.generatePuzzle(difficulty: difficulty, pieceConfig: pieceConfig);

      _currentPuzzle = puzzle;
      _currentBoard = ChessSudokuBoard.fromJson(puzzle.puzzle.toJson());
      _resetGameState();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 저장된 퍼즐 불러오기
  Future<void> getPuzzle(String puzzleId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final puzzle = await _gameService.getPuzzle(puzzleId);

      _currentPuzzle = puzzle;
      _currentBoard = ChessSudokuBoard.fromJson(puzzle.puzzle.toJson());
      _resetGameState();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 게임 상태 초기화
  void _resetGameState() {
    selectedRow = null;
    selectedCol = null;
    _mistakes = 0;
    _hintsUsed = 0;
    _elapsedTime = Duration.zero;
    _showHints = false;
  }

  /// 셀 선택
  void selectCell(int row, int col) {
    // 체스 기물이 있는 셀은 선택 불가
    if (_currentBoard?.board[row][col] is String) {
      return;
    }

    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  /// 선택된 셀에 숫자 입력
  void enterNumber(int number) {
    if (!hasSelectedCell || _currentBoard == null) return;

    if (_currentBoard!.isValidNumber(selectedRow!, selectedCol!, number)) {
      _currentBoard!.placeNumber(selectedRow!, selectedCol!, number);

      // 입력된 숫자가 정답과 다른 경우
      if (_currentPuzzle != null && _currentPuzzle!.solution.board[selectedRow!][selectedCol!] != number) {
        _mistakes++;
      }

      notifyListeners();

      // 퍼즐이 완성되었는지 확인
      if (isPuzzleCompleted()) {
        // TODO: 게임 완료 처리
        print("완료");
      }
    }
  }

  /// 선택된 셀의 숫자 지우기
  void eraseNumber() {
    if (!hasSelectedCell || _currentBoard == null) return;

    _currentBoard!.removeNumber(selectedRow!, selectedCol!);
    notifyListeners();
  }

  /// 힌트 토글
  void toggleHints() {
    _showHints = !_showHints;
    if (_showHints) {
      _hintsUsed++;
    }
    notifyListeners();
  }

  /// 현재 위치에서 가능한 숫자들 반환
  Set<int> getValidNumbers(int row, int col) {
    if (_currentBoard == null) return {};

    final validNumbers = <int>{};
    for (var num = 1; num <= 9; num++) {
      if (_currentBoard!.isValidNumber(row, col, num)) {
        validNumbers.add(num);
      }
    }
    return validNumbers;
  }

  /// 퍼즐이 완성되었는지 확인
  bool isPuzzleCompleted() {
    if (_currentBoard == null || _currentPuzzle == null) return false;

    // 모든 셀 검사
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        final currentCell = _currentBoard!.board[i][j];
        final solutionCell = _currentPuzzle!.solution.board[i][j];

        // 체스 기물이 아닌 셀만 비교
        if (currentCell is! String && solutionCell is! String) {
          if (currentCell != solutionCell) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// 선택된 셀 초기화
  void clearSelection() {
    selectedRow = null;
    selectedCol = null;
    notifyListeners();
  }
}
