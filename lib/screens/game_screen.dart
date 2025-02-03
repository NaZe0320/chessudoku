import 'package:chessudoku/widgets/board/sudoku_board.dart';
import 'package:flutter/material.dart';
import 'package:chessudoku/models/game_state.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
  }

  void _onCellTap(int row, int col) {
    // TODO: 셀 탭 처리 구현
    print('Cell tapped: [$row, $col]');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess Sudoku')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SudokuBoard(board: _gameState.currentBoard, onCellTap: _onCellTap),
        ),
      ),
    );
  }
}
