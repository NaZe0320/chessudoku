import 'package:chessudoku/providers/ad_provider.dart';
import 'package:chessudoku/providers/authentication_provider.dart';
import 'package:chessudoku/providers/chance_provider.dart';
import 'package:chessudoku/screens/game_screen.dart';
import 'package:chessudoku/screens/record_screen.dart';
import 'package:chessudoku/services/api_service.dart';
import 'package:chessudoku/utils/converts.dart';
import 'package:chessudoku/utils/helpers.dart';
import 'package:chessudoku/widgets/dialogs/warning_dialog.dart';
import 'package:chessudoku/widgets/dialogs/watch_ad_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiService _apiService;
  bool _hasSavedGame = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _checkSavedGame();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final hasGame = prefs.getString('game_progress') != null;
    setState(() {
      _hasSavedGame = hasGame;
    });
  }

  Future<void> _startNewGame(BuildContext context) async {
    final chanceProvider = context.read<ChanceProvider>();

    if (chanceProvider.currentChances > 0) {
      if (_hasSavedGame) {
        final shouldContinue = await showDialog<bool>(context: context, builder: (context) => const WarningDialog());

        if (shouldContinue != true) return;

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('game_progress');
      }

      _showDifficultyDialog(context);
    } else {
      _showWatchAdDialog(context);
    }
  }

  Future<void> _startGame(BuildContext context, String difficulty) async {
    setState(() => _isLoading = true);
    try {
      final puzzleData = await _apiService.fetchPuzzle(difficulty);
      // Firebase에서 퍼즐을 성공적으로 받아왔을 때만 기회 소모
      final success = await context.read<ChanceProvider>().useChance();
      if (success) {
        if (!mounted) return;
        Navigator.of(context).pop(); // 난이도 선택 다이얼로그 닫기

        final gameState = convertPuzzleToGameState(puzzleData);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(gameState: gameState)),
        ).then((_) => _checkSavedGame());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load puzzle: ${e.toString()}')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chanceProvider = context.watch<ChanceProvider>();

    if (!chanceProvider.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 게임 타이틀
                  Text(
                    'ChesSudoku',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [const Shadow(offset: Offset(2, 2), blurRadius: 3.0, color: Colors.black26)],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 부제목
                  Text(
                    'A unique blend of Chess and Sudoku',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),
                  // 폰 기회 표시
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '♟',
                                style: TextStyle(
                                  fontSize: 24,
                                  color:
                                      index < chanceProvider.currentChances
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                ),
                              ),
                            );
                          }),
                        ),
                        if (chanceProvider.currentChances < 5 && chanceProvider.nextRecharge != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.timer, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            formatDuration(chanceProvider.nextRecharge!),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 새 게임 시작 버튼
                  _MenuButton(icon: Icons.play_arrow, label: 'New Game', onPressed: () => _startNewGame(context)),

                  const SizedBox(height: 16),

                  // 게임 이어하기 버튼
                  _MenuButton(
                    icon: Icons.refresh,
                    label: 'Continue Game',
                    onPressed:
                        _hasSavedGame
                            ? () async {
                              final prefs = await SharedPreferences.getInstance();
                              final savedGameJson = prefs.getString('game_progress');
                              if (savedGameJson != null) {
                                final savedGameState = convertJsonToGameState(savedGameJson);
                                if (savedGameState != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => GameScreen(gameState: savedGameState)),
                                  ).then((_) => _checkSavedGame());
                                }
                              }
                            }
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // 기록실 버튼
                  _MenuButton(
                    icon: Icons.emoji_events,
                    label: 'Records',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecordScreen()),
                      ).then((_) => _checkSavedGame());
                    },
                  ),

                  const SizedBox(height: 16),

                  // 튜토리얼 버튼
                  _MenuButton(
                    icon: Icons.school,
                    label: 'How to Play',
                    onPressed: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => const TutorialScreen()));
                    },
                  ),

                  const SizedBox(height: 16),

                  // 설정 버튼
                  // _MenuButton(
                  //   icon: Icons.settings,
                  //   label: 'Settings',
                  //   onPressed: () {
                  //     // TODO: Navigate to settings screen
                  //   },
                  // ),
                  const SizedBox(height: 16),

                  // 체스 기물 아이콘들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('♚', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♝', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♞', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♜', style: TextStyle(color: Colors.white, fontSize: 32)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showWatchAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => WatchAdDialog(
            nextRecharge: context.read<ChanceProvider>().nextRecharge,
            onWatchAd: () {
              Navigator.pop(context);
              _showRewardedAd().then((_) async {
                if (context.read<ChanceProvider>().currentChances > 0) {
                  if (_hasSavedGame) {
                    final shouldContinue = await showDialog<bool>(
                      context: context,
                      builder: (context) => const WarningDialog(),
                    );

                    if (shouldContinue != true) return;

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('game_progress');
                  }
                  _showDifficultyDialog(context);
                }
              });
            },
          ),
    );
  }

  // 광고 시청 메서드 수정
  Future<void> _showRewardedAd() async {
    setState(() => _isLoading = true);
    try {
      final adProvider = context.read<AdProvider>();
      final success = await adProvider.showRewardedAd();

      if (success) {
        await context.read<ChanceProvider>().addChance();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chance added successfully!')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to complete ad viewing. Please try again.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to show ad. Please try again.')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder:
          (context) => Stack(
            children: [
              Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Select Difficulty', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _DifficultyOption(
                        difficulty: 'Easy',
                        description: '41-46 hints',
                        color: Colors.green,
                        onTap: _isLoading ? null : () => _startGame(context, 'easy'),
                      ),
                      const SizedBox(height: 12),
                      _DifficultyOption(
                        difficulty: 'Medium',
                        description: '31-36 hints',
                        color: Colors.orange,
                        onTap: _isLoading ? null : () => _startGame(context, 'medium'),
                      ),
                      const SizedBox(height: 12),
                      _DifficultyOption(
                        difficulty: 'Hard',
                        description: '21-26 hints',
                        color: Colors.red,
                        onTap: _isLoading ? null : () => _startGame(context, 'hard'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading) const Positioned.fill(child: Center(child: CircularProgressIndicator())),
            ],
          ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _MenuButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade900,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 3,
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: onPressed == null ? Colors.grey : null),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onPressed == null ? Colors.grey : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final String difficulty;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const _DifficultyOption({
    required this.difficulty,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: color), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.star, size: 16, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(difficulty, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
