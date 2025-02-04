import 'package:chessudoku/providers/game_provider.dart';
import 'package:chessudoku/services/storage_service.dart';
import 'package:chessudoku/widgets/board/game_controls.dart';
import 'package:chessudoku/widgets/board/number_pad.dart';
import 'package:chessudoku/widgets/board/sudoku_board.dart';
import 'package:flutter/material.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  GameProvider? _gameProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameProvider?.dispose(); // null check 추가
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_gameProvider == null) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _gameProvider?.onBackground();
        break;
      case AppLifecycleState.resumed:
        _gameProvider?.onForeground();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: StorageService.initialize(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ChangeNotifierProvider(
          create: (context) {
            _gameProvider = GameProvider(widget.gameState, context, snapshot.data!);
            return _gameProvider;
          },
          child: Consumer<GameProvider>(
            builder:
                (context, provider, _) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Chess Sudoku'),
                    centerTitle: true,
                    elevation: 0,
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () async {
                        await provider.saveGameProgress();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    actions: [
                      Consumer<GameProvider>(
                        builder:
                            (context, provider, child) => IconButton(
                              icon: Icon(provider.isPaused ? Icons.play_arrow : Icons.pause),
                              onPressed: () {
                                if (provider.isPaused) {
                                  provider.resumeTimer();
                                } else {
                                  provider.pauseTimer();
                                }
                              },
                            ),
                      ),
                    ],
                  ),
                  body: SafeArea(
                    child: Column(
                      children: [
                        // Timer and stats
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.blue.shade900,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Timer
                              Consumer<GameProvider>(
                                builder:
                                    (context, provider, child) => Row(
                                      children: [
                                        const Icon(Icons.timer, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          provider.formattedTime,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                spacing: 16.0,
                                children: [
                                  // Sudoku board
                                  const SudokuBoard(),
                                  // 메모 모드 토글 버튼
                                  const GameControls(),
                                  // Number pad
                                  const NumberPad(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        );
      },
    );
  }
}
