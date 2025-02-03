import 'package:chessudoku/models/game_state.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    print("게임 상태 : ${widget.gameState}");
    return const Placeholder();
  }
}
