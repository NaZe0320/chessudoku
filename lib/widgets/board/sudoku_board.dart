import 'package:chessudoku/providers/game_provider.dart';
import 'package:chessudoku/widgets/board/board_cell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxHeight = screenHeight * 0.6; // 화면 높이의 60%를 최대 높이로 설정

    // 가로/세로 중 작은 값을 보드 크기로 사용
    final boardSize = [maxHeight, screenWidth - 32].reduce((a, b) => a < b ? a : b);

    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: Center(
              child: SizedBox(
                width: boardSize,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      final row = index ~/ 9;
                      final col = index % 9;
                      final cell = gameProvider.currentBoard.getCell(row, col);

                      return BoardCell(key: Key('cell_$row$col'), row: row, col: col, cell: cell);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
