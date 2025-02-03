import 'package:chessudoku/enums/chess_piece.dart';
import 'package:chessudoku/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:chessudoku/models/board.dart';
import 'package:chessudoku/models/cell.dart';
import 'package:provider/provider.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return AspectRatio(
          aspectRatio: 1, // 정사각형 보드
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                return _buildCell(row, col, gameProvider);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(int row, int col, GameProvider gameProvider) {
    final cell = gameProvider.currentBoard.getCell(row, col);
    final isSelected = gameProvider.isCellSelected(row, col);
    final isHighlighted = gameProvider.isCellHighlighted(row, col);

    // 3x3 박스 구분을 위한 테두리 설정
    final borderSide = BorderSide(color: Colors.grey.shade400, width: 0.5);
    final boldBorderSide = BorderSide(color: Colors.grey.shade400, width: 2.0);

    // 셀 배경색 결정
    Color backgroundColor = Colors.white;
    if (isSelected) {
      backgroundColor = Colors.blue.shade200; // 선택된 셀
    } else if (isHighlighted) {
      backgroundColor = Colors.blue.shade50; // 하이라이트된 셀 (연한 파란색)
    }

    return GestureDetector(
      onTap: () => gameProvider.selectCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: row % 3 == 0 ? boldBorderSide : borderSide,
            left: col % 3 == 0 ? boldBorderSide : borderSide,
            right: BorderSide.none,
            bottom: BorderSide.none,
          ),
        ),
        child: Center(child: _buildCellContent(cell)),
      ),
    );
  }

  Widget _buildCellContent(Cell cell) {
    if (cell.piece != null) {
      return Text(_getPieceSymbol(cell.piece!), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
    }

    if (cell.number != null) {
      return Text(
        cell.number.toString(),
        style: TextStyle(
          fontSize: 24,
          color: cell.isInitial ? Colors.black : Colors.blue,
          fontWeight: cell.isInitial ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getPieceSymbol(ChessPiece piece) {
    switch (piece) {
      case ChessPiece.king:
        return '♚';
      case ChessPiece.bishop:
        return '♝';
      case ChessPiece.knight:
        return '♞';
      case ChessPiece.rook:
        return '♜';
    }
  }
}
