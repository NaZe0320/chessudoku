import 'package:chessudoku/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cell.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (gameProvider.error.isNotEmpty) {
          return Center(child: Text('Error: ${gameProvider.error}', style: const TextStyle(color: Colors.red)));
        }

        if (gameProvider.currentBoard == null) {
          return const Center(child: Text('No puzzle loaded'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final borderWidth = 2.0;
            final totalBorderWidth = borderWidth * 2; // 좌우 테두리의 총 너비
            final availableWidth = constraints.maxWidth - totalBorderWidth;
            final cellSize = availableWidth / 9;

            return Container(
              width: constraints.maxWidth,
              height: constraints.maxWidth,
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: borderWidth)),
              child: Column(
                children: List.generate(9, (row) {
                  return Row(
                    children: List.generate(9, (col) {
                      return SizedBox(
                        width: cellSize,
                        height: cellSize,
                        child: Stack(
                          children: [
                            // Cell border
                            _buildCellBorder(row, col),

                            // Cell content
                            GameCell(
                              row: row,
                              col: col,
                              value: gameProvider.currentBoard!.board[row][col],
                              isSelected:
                                  gameProvider.hasSelectedCell &&
                                  row == gameProvider.selectedRow &&
                                  col == gameProvider.selectedCol,
                              onTap: () => gameProvider.selectCell(row, col),
                              validNumbers: gameProvider.showHints ? gameProvider.getValidNumbers(row, col) : const {},
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCellBorder(int row, int col) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: row % 3 == 0 ? 2 : 1, color: Colors.black),
          left: BorderSide(width: col % 3 == 0 ? 2 : 1, color: Colors.black),
          right: BorderSide(width: 1, color: Colors.black),
          bottom: BorderSide(width: 1, color: Colors.black),
        ),
      ),
    );
  }
}

// Gesture handlers for the board
mixin GameBoardGestures {
  void onCellTap(BuildContext context, int row, int col) {
    final gameProvider = context.read<GameProvider>();
    gameProvider.selectCell(row, col);
  }

  void onNumberInput(BuildContext context, int number) {
    final gameProvider = context.read<GameProvider>();
    gameProvider.enterNumber(number);
  }

  void onErase(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    gameProvider.eraseNumber();
  }
}
