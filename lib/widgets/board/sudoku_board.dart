import 'package:chessudoku/providers/game_provider.dart';
import 'package:chessudoku/widgets/board/board_cell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.6;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (maxHeight < screenWidth) ? maxHeight : screenWidth;

    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Center(
          child: SizedBox(
            height: maxHeight,
            child: Center(
              child: SizedBox(
                width: boardSize,
                height: boardSize,
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
