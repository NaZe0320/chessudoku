import 'dart:convert';
import 'package:chessudoku/test/mock_data.dart';
import 'package:dio/dio.dart';
import '../models/board.dart';

/// 체스 스도쿠 게임 관련 서비스를 제공하는 클래스
class GameService {
  final Dio _dio;
  final String _baseUrl;
  final bool useMock;

  GameService({String? baseUrl, Dio? dio, this.useMock = true})
    : _baseUrl = baseUrl ?? 'http://localhost:5000',
      _dio = dio ?? Dio();

  /// 새로운 체스 스도쿠 퍼즐 생성 요청
  Future<ChessSudokuPuzzle> generatePuzzle({String difficulty = 'medium', List<PieceConfig>? pieceConfig}) async {
    try {
      if (useMock) {
        // Mock 데이터 사용
        final mockResponse = await MockData.getMockPuzzle(difficulty);
        return ChessSudokuPuzzle.fromJson(mockResponse);
      }

      final response = await _dio.post(
        '$_baseUrl/generate',
        data: {'difficulty': difficulty, 'pieces': pieceConfig?.map((config) => config.toJson()).toList()},
      );

      if (response.statusCode == 200) {
        return ChessSudokuPuzzle.fromJson(response.data);
      } else {
        throw Exception('Failed to generate puzzle: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// 특정 ID의 퍼즐 불러오기
  Future<ChessSudokuPuzzle> getPuzzle(String puzzleId) async {
    try {
      if (useMock) {
        // puzzleId에서 난이도 추출 (예: 'easy_puzzle_1' -> 'easy')
        final difficulty = puzzleId.split('_').first;
        final mockResponse = await MockData.getMockPuzzle(difficulty);
        return ChessSudokuPuzzle.fromJson(mockResponse);
      }

      final response = await _dio.get('$_baseUrl/puzzles/$puzzleId');

      if (response.statusCode == 200) {
        return ChessSudokuPuzzle.fromJson(response.data);
      } else {
        throw Exception('Failed to load puzzle: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

/// 체스 기물 설정을 위한 클래스
class PieceConfig {
  final String type;
  final List<int> position;

  PieceConfig({required this.type, required this.position});

  Map<String, dynamic> toJson() => {'type': type, 'position': position};

  factory PieceConfig.fromJson(Map<String, dynamic> json) =>
      PieceConfig(type: json['type'] as String, position: List<int>.from(json['position']));
}

class ChessSudokuPuzzle {
  final String puzzleId;
  final ChessSudokuBoard puzzle;
  final ChessSudokuBoard solution;
  final List<RemovedCell> removedCells;
  final String difficulty;

  ChessSudokuPuzzle({
    required this.puzzleId,
    required this.puzzle,
    required this.solution,
    required this.removedCells,
    required this.difficulty,
  });

  factory ChessSudokuPuzzle.fromJson(Map<String, dynamic> json) {
    final puzzleData = json['puzzle_data'];

    // removed_cells가 null이면 빈 리스트 사용
    final removedCellsList = puzzleData['removed_cells'] as List?;
    final removedCells =
        removedCellsList != null
            ? removedCellsList.map((cell) => RemovedCell.fromJson(cell)).toList()
            : <RemovedCell>[];

    return ChessSudokuPuzzle(
      puzzleId: json['puzzle_id'] as String,
      puzzle: ChessSudokuBoard.fromJson(puzzleData['puzzle']),
      solution: ChessSudokuBoard.fromJson(puzzleData['solution']),
      removedCells: removedCells,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'puzzle_id': puzzleId,
    'puzzle_data': {
      'puzzle': puzzle.toJson(),
      'solution': solution.toJson(),
      'removed_cells': removedCells.map((cell) => cell.toJson()).toList(),
    },
    'difficulty': difficulty,
  };
}

/// 제거된 셀의 정보를 담는 클래스
class RemovedCell {
  final int row;
  final int col;
  final int value;

  RemovedCell({required this.row, required this.col, required this.value});

  factory RemovedCell.fromJson(List<dynamic> json) =>
      RemovedCell(row: json[0] as int, col: json[1] as int, value: json[2] as int);

  List<dynamic> toJson() => [row, col, value];
}
