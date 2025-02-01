import 'dart:convert';
import 'package:chessudoku/models/game_state.dart';

GameState convertJsonToGameState(String jsonString) {
  // JSON 문자열을 Map으로 디코딩
  final Map<String, dynamic> jsonMap = json.decode(jsonString);

  // Board 객체들의 JSON을 완성
  // 현재 JSON이 불완전해 보이므로, 나머지 셀들을 빈 셀로 채움
  final int boardSize = 9;
  List<List<Map<String, dynamic>>> completeCells = List.generate(
    boardSize,
    (i) =>
        List.generate(boardSize, (j) => {'type': 'CellType.empty', 'number': null, 'piece': null, 'isInitial': false}),
  );

  // 주어진 JSON의 cells 데이터로 업데이트
  if (jsonMap['initialBoard'] != null && jsonMap['initialBoard']['cells'] != null) {
    var sourceCells = jsonMap['initialBoard']['cells'];
    for (var i = 0; i < sourceCells.length; i++) {
      for (var j = 0; j < sourceCells[i].length; j++) {
        completeCells[i][j] = sourceCells[i][j];
      }
    }
  }

  // 완성된 보드 JSON 생성
  final completeBoard = {'cells': completeCells};

  // GameState 생성을 위한 완성된 JSON 맵 생성
  final completeJsonMap = {
    'puzzleId': jsonMap['puzzleId'] ?? 'default_puzzle',
    'status': jsonMap['status'] ?? 'GameStatus.playing',
    'initialBoard': completeBoard,
    'currentBoard': completeBoard, // 초기에는 initialBoard와 동일
    'solutionBoard': completeBoard, // 실제 솔루션은 별도로 설정 필요
    'hintsUsed': 0,
    'startTime': DateTime.now().toIso8601String(),
    'elapsedSeconds': 0,
    'selectedCell': [-1, -1],
  };

  // GameState 객체 생성 및 반환
  return GameState.fromJson(completeJsonMap);
}
