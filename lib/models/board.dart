import 'dart:convert';
import 'package:equatable/equatable.dart';

/// 체스 스도쿠 보드의 상태를 나타내는 클래스
class ChessSudokuBoard extends Equatable {
  /// 9x9 보드 (null: 빈 칸, int: 숫자, String: 체스 기물)
  final List<List<dynamic>> board;

  /// 체스 기물 유니코드 문자
  static const Map<String, String> pieces = {'king': '♚', 'bishop': '♝', 'knight': '♞', 'rook': '♜'};

  /// 각 기물의 위치 저장
  final Map<String, List<List<int>>> piecePositions;

  ChessSudokuBoard({List<List<dynamic>>? board, Map<String, List<List<int>>>? piecePositions})
    : board = board ?? List.generate(9, (_) => List.filled(9, null)),
      piecePositions = piecePositions ?? {'king': [], 'bishop': [], 'knight': [], 'rook': []};

  /// 특정 위치에 체스 기물을 배치
  bool placePiece(String piece, int row, int col) {
    if (!pieces.containsKey(piece) || row < 0 || row >= 9 || col < 0 || col >= 9) {
      return false;
    }

    board[row][col] = pieces[piece];
    piecePositions[piece]!.add([row, col]);
    return true;
  }

  /// 나이트의 이동 가능한 위치 반환
  List<List<int>> getKnightMoves(int row, int col) {
    final moves = [
      [row - 2, col - 1],
      [row - 2, col + 1],
      [row - 1, col - 2],
      [row - 1, col + 2],
      [row + 1, col - 2],
      [row + 1, col + 2],
      [row + 2, col - 1],
      [row + 2, col + 1],
    ];

    return moves.where((move) => move[0] >= 0 && move[0] < 9 && move[1] >= 0 && move[1] < 9).toList();
  }

  /// 비숍의 대각선 이동 가능한 위치 반환
  List<List<int>> getBishopDiagonals(int row, int col) {
    final List<List<int>> diagonals = [];

    // 메인 대각선 (↘️)
    var r = row - 1;
    var c = col - 1;
    while (r >= 0 && c >= 0) {
      if (board[r][c] is! String) {
        diagonals.add([r, c]);
      } else {
        break;
      }
      r--;
      c--;
    }

    r = row + 1;
    c = col + 1;
    while (r < 9 && c < 9) {
      if (board[r][c] is! String) {
        diagonals.add([r, c]);
      } else {
        break;
      }
      r++;
      c++;
    }

    // 반대 대각선 (↙️)
    r = row - 1;
    c = col + 1;
    while (r >= 0 && c < 9) {
      if (board[r][c] is! String) {
        diagonals.add([r, c]);
      } else {
        break;
      }
      r--;
      c++;
    }

    r = row + 1;
    c = col - 1;
    while (r < 9 && c >= 0) {
      if (board[r][c] is! String) {
        diagonals.add([r, c]);
      } else {
        break;
      }
      r++;
      c--;
    }

    return diagonals;
  }

  /// 킹의 이동 가능한 위치 반환
  List<List<int>> getKingMoves(int row, int col) {
    final moves = [
      [row - 1, col - 1],
      [row - 1, col],
      [row - 1, col + 1],
      [row, col - 1],
      [row, col + 1],
      [row + 1, col - 1],
      [row + 1, col],
      [row + 1, col + 1],
    ];

    return moves.where((move) => move[0] >= 0 && move[0] < 9 && move[1] >= 0 && move[1] < 9).toList();
  }

  /// 해당 위치의 숫자들 가져오기
  List<int> getNumbersInPositions(List<List<int>> positions) {
    return positions.where((pos) => board[pos[0]][pos[1]] is int).map((pos) => board[pos[0]][pos[1]] as int).toList();
  }

  /// 주어진 위치에 숫자를 놓을 수 있는지 확인
  bool isValidNumber(int row, int col, int num) {
    // 체스 기물이 있는 칸인지 확인
    if (board[row][col] is String && pieces.containsValue(board[row][col])) {
      return false;
    }

    // 1-9 범위 확인
    if (num < 1 || num > 9) {
      return false;
    }

    // 행 검사
    if (board[row].any((cell) => cell == num)) {
      return false;
    }

    // 열 검사
    if (board.any((row) => row[col] == num)) {
      return false;
    }

    // 3x3 박스 검사
    final boxRow = 3 * (row ~/ 3);
    final boxCol = 3 * (col ~/ 3);
    for (var i = boxRow; i < boxRow + 3; i++) {
      for (var j = boxCol; j < boxCol + 3; j++) {
        if (board[i][j] == num) {
          return false;
        }
      }
    }

    // 나이트 규칙 검사
    for (var knightPos in piecePositions['knight']!) {
      final moves = getKnightMoves(knightPos[0], knightPos[1]);
      if (moves.any((move) => move[0] == row && move[1] == col)) {
        final numbers = getNumbersInPositions(moves);
        if (numbers.contains(num)) {
          return false;
        }
      }
    }

    // 비숍 규칙 검사
    for (var bishopPos in piecePositions['bishop']!) {
      final diagonals = getBishopDiagonals(bishopPos[0], bishopPos[1]);
      if (diagonals.any((pos) => pos[0] == row && pos[1] == col)) {
        final numbers = getNumbersInPositions(diagonals);
        if (numbers.contains(num)) {
          return false;
        }
      }
    }

    // 킹 규칙 검사
    for (var kingPos in piecePositions['king']!) {
      final moves = getKingMoves(kingPos[0], kingPos[1]);
      if (moves.any((move) => move[0] == row && move[1] == col)) {
        final numbers = getNumbersInPositions(moves);
        if (numbers.contains(num)) {
          return false;
        }
      }
    }

    return true;
  }

  /// 숫자를 보드에 배치
  bool placeNumber(int row, int col, int num) {
    if (!isValidNumber(row, col, num)) {
      return false;
    }
    board[row][col] = num;
    return true;
  }

  /// 숫자 제거
  void removeNumber(int row, int col) {
    if (board[row][col] is int) {
      board[row][col] = null;
    }
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'board': board.map((row) => row.map((cell) => cell is String ? cell : cell?.toString()).toList()).toList(),
      'piecePositions': piecePositions.map((key, value) => MapEntry(key, value.map((pos) => pos.toList()).toList())),
    };
  }

  /// JSON 역직렬화
  factory ChessSudokuBoard.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ChessSudokuBoard();
    }

    // board 파싱
    List<List<dynamic>> parsedBoard;
    try {
      final boardData = json['board'] as List?;
      if (boardData == null) {
        parsedBoard = List.generate(9, (_) => List.filled(9, null));
      } else {
        parsedBoard =
            boardData.map((row) {
              if (row is! List) return List.filled(9, null);
              return row.map((cell) {
                if (cell == null || cell == 'null') return null;
                // 체스 기물인 경우
                if (cell is String && pieces.containsValue(cell)) return cell;
                // 숫자로 변환 시도
                return int.tryParse(cell.toString());
              }).toList();
            }).toList();
      }
    } catch (e) {
      print('Error parsing board: $e');
      parsedBoard = List.generate(9, (_) => List.filled(9, null));
    }

    // piecePositions 파싱
    final Map<String, List<List<int>>> parsedPiecePositions = {'king': [], 'bishop': [], 'knight': [], 'rook': []};

    try {
      final positionsData = json['piecePositions'] as Map<String, dynamic>?;
      if (positionsData != null) {
        positionsData.forEach((key, value) {
          if (parsedPiecePositions.containsKey(key) && value is List) {
            parsedPiecePositions[key] =
                value.map((pos) {
                  if (pos is List) {
                    return pos.map((n) => n is int ? n : 0).toList().sublist(0, 2);
                  }
                  return <int>[0, 0];
                }).toList();
          }
        });
      }
    } catch (e) {
      print('Error parsing piece positions: $e');
    }

    return ChessSudokuBoard(board: parsedBoard, piecePositions: parsedPiecePositions);
  }

  @override
  List<Object?> get props => [board, piecePositions];

  /// 보드 출력 (디버깅용)
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('┌───────────────────────┐');

    for (var i = 0; i < 9; i++) {
      buffer.write('│ ');
      for (var j = 0; j < 9; j++) {
        final cell = board[i][j];
        if (cell == null) {
          buffer.write('. ');
        } else {
          buffer.write('$cell ');
        }

        if (j % 3 == 2 && j < 8) {
          buffer.write('│ ');
        }
      }
      buffer.writeln('│');

      if (i % 3 == 2 && i < 8) {
        buffer.writeln('├───────────────────────┤');
      }
    }

    buffer.writeln('└───────────────────────┘');
    return buffer.toString();
  }
}
