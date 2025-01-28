import '../models/board.dart';

/// 테스트용 mock 데이터
class MockData {
  /// 게임 모드별 예제 퍼즐
  static final Map<String, Map<String, dynamic>> mockPuzzles = {
    'easy': {
      'puzzle_id': 'easy_puzzle_1',
      'puzzle_data': {
        'puzzle': {
          'board': [
            [null, null, '♞', null, null, 7, null, null, 1],
            [null, 3, null, null, null, null, null, 5, null],
            [null, null, null, 2, null, null, null, null, null],
            [null, null, null, '♝', null, null, 2, null, null],
            [null, null, 4, null, null, null, 6, null, null],
            [null, null, 1, null, null, null, null, null, null],
            [null, null, null, null, null, 3, null, null, null],
            [null, 1, null, null, null, null, '♚', null, null],
            [2, null, null, 6, null, null, null, null, null],
          ],
          'piece_positions': {
            'king': [
              [7, 6],
            ],
            'bishop': [
              [3, 3],
            ],
            'knight': [
              [0, 2],
              [4, 7],
            ],
            'rook': [],
          },
        },
        'solution': {
          'board': [
            [5, 4, '♞', 8, 6, 7, 3, 2, 1],
            [8, 3, 2, 1, 4, 9, 7, 5, 6],
            [1, 6, 7, 2, 3, 5, 4, 8, 9],
            [7, 8, 5, '♝', 1, 6, 2, 9, 3],
            [3, 2, 4, 9, 8, 1, 6, 7, 5],
            [6, 9, 1, 5, 7, 2, 8, 3, 4],
            [9, 5, 8, 7, 2, 3, 1, 4, 6],
            [4, 1, 3, 8, 5, 9, '♚', 6, 7],
            [2, 7, 9, 6, 4, 8, 5, 1, 3],
          ],
          'piece_positions': {
            'king': [
              [7, 6],
            ],
            'bishop': [
              [3, 3],
            ],
            'knight': [
              [0, 2],
              [4, 7],
            ],
            'rook': [],
          },
        },
        'removed_cells': [
          [0, 0, 5], [0, 1, 4], [0, 4, 6], [0, 6, 3], [0, 7, 2],
          [1, 0, 8], [1, 2, 2], [1, 3, 1], [1, 4, 4], [1, 5, 9], [1, 6, 7],
          // ... (제거된 셀들의 정보)
        ],
      },
      'difficulty': 'easy',
    },
    'medium': {
      'puzzle_id': 'medium_puzzle_1',
      'puzzle_data': {
        'puzzle': {
          'board': [
            [null, null, '♞', null, null, null, null, null, null],
            [null, null, null, null, '♜', null, null, null, null],
            [null, null, null, null, null, null, null, 3, null],
            [null, null, null, '♝', null, null, null, null, null],
            [null, 5, null, null, null, null, null, null, null],
            [null, null, null, null, null, '♚', null, null, null],
            [null, 2, null, null, null, null, null, null, null],
            [null, null, null, null, null, null, 4, null, null],
            [null, null, null, null, 1, null, null, null, null],
          ],
          'piece_positions': {
            'king': [
              [5, 5],
            ],
            'bishop': [
              [3, 3],
            ],
            'knight': [
              [0, 2],
            ],
            'rook': [
              [1, 4],
            ],
          },
        },
        'solution': {
          'board': [
            [4, 1, '♞', 8, 2, 6, 7, 9, 5],
            [6, 8, 2, 7, '♜', 9, 3, 1, 4],
            [7, 9, 5, 4, 1, 8, 6, 3, 2],
            [2, 6, 8, '♝', 7, 4, 9, 5, 1],
            [1, 5, 9, 2, 3, 7, 8, 4, 6],
            [3, 4, 7, 9, 8, '♚', 1, 2, 5],
            [9, 2, 1, 5, 4, 3, 7, 6, 8],
            [5, 7, 6, 1, 9, 2, 4, 8, 3],
            [8, 3, 4, 6, 1, 5, 2, 7, 9],
          ],
          'piece_positions': {
            'king': [
              [5, 5],
            ],
            'bishop': [
              [3, 3],
            ],
            'knight': [
              [0, 2],
            ],
            'rook': [
              [1, 4],
            ],
          },
        },
        'removed_cells': [
          // ... (제거된 셀들의 정보)
        ],
      },
      'difficulty': 'medium',
    },
    'hard': {
      'puzzle_id': 'hard_puzzle_1',
      'puzzle_data': {
        'puzzle': {
          'board': [
            [null, null, '♞', null, null, null, null, null, null],
            [null, null, null, null, null, null, '♜', null, null],
            [null, null, null, null, 2, null, null, null, null],
            [null, null, null, '♝', null, null, null, null, null],
            [null, null, null, null, null, null, null, 4, null],
            [null, 1, null, null, null, '♚', null, null, null],
            [null, null, null, null, 3, null, null, null, null],
            [null, null, null, null, null, null, null, null, 2],
            [null, null, null, 1, null, null, null, null, null],
          ],
          'piece_positions': {
            'king': [
              [5, 5],
            ],
            'bishop': [
              [3, 3],
            ],
            'knight': [
              [0, 2],
            ],
            'rook': [
              [1, 6],
            ],
          },
        },
        'solution': {
          'board': [
            [7, 4, '♞', 2, 1, 8, 5, 6, 9],
            [2, 5, 8, 6, 9, 4, '♜', 1, 3],
            [1, 9, 6, 5, 2, 3, 4, 8, 7],
            [5, 2, 9, '♝', 4, 1, 3, 7, 8],
            [8, 7, 3, 9, 5, 2, 1, 4, 6],
            [4, 1, 5, 8, 7, '♚', 9, 2, 3],
            [9, 8, 2, 7, 3, 5, 6, 4, 1],
            [3, 6, 7, 4, 8, 9, 5, 1, 2],
            [6, 5, 4, 1, 2, 7, 8, 3, 9],
          ],
          'piece_positions': {
            'king': [
              [5, 5],
            ],
            'bishop': [
              [3, 3],
            ],
            'knight': [
              [0, 2],
            ],
            'rook': [
              [1, 6],
            ],
          },
        },
        'removed_cells': [
          // ... (제거된 셀들의 정보)
        ],
      },
      'difficulty': 'hard',
    },
  };

  /// Mock API 응답 시뮬레이션
  static Future<Map<String, dynamic>> getMockPuzzle(String difficulty) async {
    // 실제 API 호출을 시뮬레이션하기 위한 지연
    await Future.delayed(const Duration(seconds: 1));

    if (!mockPuzzles.containsKey(difficulty)) {
      throw Exception('Invalid difficulty level');
    }

    return mockPuzzles[difficulty]!;
  }

  /// Mock 게임 저장 데이터
  static const Map<String, dynamic> mockGameState = {
    'current_puzzle_id': 'easy_puzzle_1',
    'elapsed_time': 360, // 6분
    'mistakes': 2,
    'hints_used': 1,
    'is_completed': false,
  };
}

/// Mock 리더보드 데이터
class MockLeaderboard {
  static const List<Map<String, dynamic>> entries = [
    {'rank': 1, 'player_name': 'GrandMaster', 'completion_time': 245, 'difficulty': 'hard', 'date': '2025-01-27'},
    {'rank': 2, 'player_name': 'ChessWhiz', 'completion_time': 312, 'difficulty': 'hard', 'date': '2025-01-26'},
    {'rank': 3, 'player_name': 'SudokuKing', 'completion_time': 328, 'difficulty': 'hard', 'date': '2025-01-25'},
  ];
}

/// Mock 업적 데이터
class MockAchievements {
  static const List<Map<String, dynamic>> achievements = [
    {
      'id': 'first_win',
      'title': 'First Victory',
      'description': 'Complete your first puzzle',
      'is_unlocked': true,
      'unlock_date': '2025-01-20',
    },
    {
      'id': 'speed_demon',
      'title': 'Speed Demon',
      'description': 'Complete a puzzle under 5 minutes',
      'is_unlocked': false,
      'progress': 0.8, // 80% 달성
    },
    {
      'id': 'perfect_game',
      'title': 'Perfect Game',
      'description': 'Complete a puzzle without any mistakes',
      'is_unlocked': false,
      'progress': 0.0,
    },
  ];
}
