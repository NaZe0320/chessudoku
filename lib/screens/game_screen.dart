import 'package:chessudoku/providers/game_provider.dart';
import 'package:chessudoku/widgets/board/sudoku_board.dart';
import 'package:flutter/material.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatelessWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(gameState),
      child: Scaffold(
        appBar: AppBar(title: const Text('Chess Sudoku')),
        body: Center(child: Padding(padding: const EdgeInsets.all(16.0), child: SudokuBoard())),
      ),
    );
  }
}
