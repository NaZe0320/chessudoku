import 'dart:convert';

import 'package:chessudoku/models/game_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static const String _gameProgressKey = 'game_progress';
  static const String _lastPlayedKey = 'last_played';

  final SharedPreferences _preferences;
  final Database _database;

  StorageService(this._preferences, this._database);

  static Future<StorageService> initialize() async {
    // SharedPreferences 초기화
    final prefs = await SharedPreferences.getInstance();

    // SQLite 데이터베이스 초기화
    final database = await _initializeDatabase();

    return StorageService(prefs, database);
  }

  static Future<Database> _initializeDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = path.join(documentsDirectory.path, 'chess_sudoku.db');
    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE user_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            difficulty TEXT NOT NULL,
            games_played INTEGER NOT NULL,
            games_completed INTEGER NOT NULL,
            best_time INTEGER,
            total_time INTEGER NOT NULL,
            total_mistakes INTEGER NOT NULL,
            last_played INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // 게임 진행 상태 저장
  Future<void> saveGameProgress(GameState state) async {
    final stateJson = state.toJson();
    await _preferences.setString(_gameProgressKey, jsonEncode(stateJson));
  }

  // 게임 진행 상태 불러오기
  Future<GameState?> loadGameProgress() async {
    final stateJson = _preferences.getString(_gameProgressKey);
    if (stateJson == null) return null;

    try {
      final Map<String, dynamic> stateMap = jsonDecode(stateJson);
      return GameState.fromJson(stateMap);
    } catch (e) {
      print('Error loading game progress: $e');
      return null;
    }
  }

  // 게임 진행 상태 삭제
  Future<void> clearGameProgress() async {
    await _preferences.remove(_gameProgressKey);
  }
}
