import 'package:chessudoku/providers/game_provider.dart';
import 'package:chessudoku/widgets/board/number_pad.dart';
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
      create: (context) => GameProvider(gameState, context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chess Sudoku'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () {
                // TODO: Implement pause functionality
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Timer and stats
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade900,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Timer
                    Row(
                      children: const [
                        Icon(Icons.timer, color: Colors.white),
                        SizedBox(width: 8),
                        Text('00:00', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8.0,
                      children: const [
                        // Sudoku board
                        SudokuBoard(),
                        // Number pad
                        NumberPad(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
