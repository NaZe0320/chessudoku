import 'package:chessudoku/models/chance_manager.dart';
import 'package:chessudoku/screens/watch_ad_dialog.dart';
import 'package:chessudoku/services/api_service.dart';
import 'package:chessudoku/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ChanceManager _chanceManager;
  late ApiService _apiService;
  int _currentChances = 5;
  Duration? _nextRecharge;
  bool _hasSavedGame = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _checkSavedGame();
    _initializeChanceManager();
  }

  Future<void> _checkSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final hasGame = prefs.getString('game_progress') != null;
    setState(() {
      _hasSavedGame = hasGame;
    });
  }

  Future<void> _initializeChanceManager() async {
    final prefs = await SharedPreferences.getInstance();
    _chanceManager = ChanceManager(prefs);
    _chanceManager.setUpdateCallback((chances, nextRecharge) {
      setState(() {
        _currentChances = chances;
        _nextRecharge = nextRecharge;
      });
    });
  }

  Future<void> _showRewardedAd() async {
    // TODO: 광고 SDK 구현
    // 광고 시청 완료 후 기회 추가
    setState(() => _isLoading = true);
    try {
      await _chanceManager.addChance();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chance added successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add chance. Please try again.')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _chanceManager.dispose();
    super.dispose();
  }

  Future<void> _startNewGame(BuildContext context) async {
    if (_currentChances > 0) {
      _showDifficultyDialog(context);
    } else {
      _showWatchAdDialog(context);
    }
  }

  Future<void> _startGame(BuildContext context, String difficulty) async {
    setState(() => _isLoading = true);
    try {
      // final puzzleData = await _apiService.fetchPuzzle(difficulty);

      // Firebase에서 퍼즐을 성공적으로 받아왔을 때만 기회 소모
      final success = await _chanceManager.useChance();
      if (success) {
        if (!mounted) return;
        Navigator.of(context).pop(); // 난이도 선택 다이얼로그 닫기
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(difficulty: difficulty /*puzzleData: puzzleData*/)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load puzzle. Please try again.')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Chess Sudoku',
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
                    child: Column(
                      children: [
                        Row(
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
                                      color: index < _currentChances ? Colors.white : Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_nextRecharge != null) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.timer, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(formatDuration(_nextRecharge!), style: const TextStyle(color: Colors.white70)),
                            ],
                          ],
                        ),
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
                            ? () {
                              // TODO: Implement continue game logic
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen()));
                            }
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // 기록실 버튼
                  _MenuButton(
                    icon: Icons.emoji_events,
                    label: 'Records',
                    onPressed: () {
                      // TODO: Navigate to records screen
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
                  _MenuButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    onPressed: () {
                      // TODO: Navigate to settings screen
                    },
                  ),

                  const SizedBox(height: 48),

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
            nextRecharge: _nextRecharge,
            onWatchAd: () {
              Navigator.pop(context);
              _showRewardedAd().then((_) {
                if (_currentChances > 0) {
                  _showDifficultyDialog(context);
                }
              });
            },
          ),
    );
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
