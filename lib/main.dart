import 'package:chessudoku/firebase_options.dart';
import 'package:chessudoku/providers/ad_provider.dart';
import 'package:chessudoku/providers/authentication_provider.dart';
import 'package:chessudoku/providers/chance_provider.dart';
import 'package:chessudoku/screens/home_screen.dart';
import 'package:chessudoku/screens/login_screen.dart';
import 'package:chessudoku/services/ad_service.dart';
import 'package:chessudoku/services/authentication_service.dart';
import 'package:chessudoku/services/chance_service.dart';
import 'package:chessudoku/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 세로 모드로 고정
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
  );

  // AdService 초기화
  final adService = AdService();
  await adService.initialize(); // AdService 초기화 먼저 실행

  // StorageService 초기화
  final storageService = await StorageService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProxyProvider<AuthProvider, ChanceProvider>(
          create: (context) => ChanceProvider('', ChanceService()),
          update: (context, auth, previous) => ChanceProvider(auth.user?.uid ?? '', ChanceService()),
        ),
        ChangeNotifierProvider(create: (_) => AdProvider(adService)),
      ],
      child: ChessSudokuApp(storageService: storageService),
    ),
  );
}

class ChessSudokuApp extends StatelessWidget {
  final StorageService storageService;

  const ChessSudokuApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Sudoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.lato().fontFamily,

        // AppBar 테마
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),

        // 버튼 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),

        // 다이얼로그 테마
        dialogTheme: DialogTheme(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5),

        // 텍스트 테마
        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.lato(fontSize: 16),
          bodyMedium: GoogleFonts.lato(fontSize: 14),
        ),

        // 아이콘 테마
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // 다크 모드 테마
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),

      // 시스템 설정에 따라 라이트/다크 모드 자동 전환
      themeMode: ThemeMode.system,

      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

// 앱 상수
class AppConstants {
  static const appName = 'Chess Sudoku';

  // API 관련 상수
  static const apiBaseUrl = 'http://localhost:5000';

  // 난이도 관련 상수
  static const difficulties = {'easy': '51-61 hints', 'medium': '51-41 hints', 'hard': '41-26 hints'};

  // 색상 상수
  static const difficultyColors = {'easy': Colors.green, 'medium': Colors.orange, 'hard': Colors.red};
}

// 라우트 이름 상수
class AppRoutes {
  static const home = '/';
  static const game = '/game';
  static const tutorial = '/tutorial';
  static const settings = '/settings';
}
