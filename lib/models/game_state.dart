import 'package:equatable/equatable.dart';

enum GameStatus {
  initial, // 게임 초기 상태
  playing, // 게임 진행 중
  paused, // 일시 정지
  completed, // 게임 완료
}

class GameState extends Equatable {
  final String puzzleId;
  final GameStatus status;

  const GameState({required this.puzzleId, required this.status});

  Map<String, dynamic> toJson() {
    return {'puzzleId': puzzleId, 'status': status};
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(puzzleId: json['puzzleId'], status: json['status']);
  }

  // 게임이 완료되었는지 확인
  bool get isCompleted => status == GameStatus.completed;

  // 게임이 진행 중인지 확인
  bool get isPlaying => status == GameStatus.playing;

  // // 힌트 사용 가능 여부 확인
  // bool get canUseHint => hintsUsed < maxHints;
  //
  // // 선택된 셀이 있는지 확인
  // bool get hasSelectedCell => selectedCell[0] != -1 && selectedCell[1] != -1;

  @override
  List<Object?> get props => throw UnimplementedError();
}
