// storage_service.dart

import 'dart:convert';
import 'package:chessudoku/models/game_record.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static const String _gameProgressKey = 'game_progress';
  static const String _lastPlayedKey = 'last_played';
  static const int _databaseVersion = 2; // 버전 증가

  final SharedPreferences _preferences;
  final Database _database;

  StorageService(this._preferences, this._database);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final database = await _initializeDatabase();
    return StorageService(prefs, database);
  }

  static Future<Database> _initializeDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = path.join(documentsDirectory.path, 'chess_sudoku.db');

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await _createTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // 버전 업그레이드 시 테이블 재생성
        await _createTables(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    // 기존 테이블이 있다면 삭제
    await db.execute('DROP TABLE IF EXISTS game_records');

    // 테이블 새로 생성
    await db.execute('''
      CREATE TABLE game_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        difficulty TEXT NOT NULL,
        elapsed_seconds INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        hints_used INTEGER NOT NULL,
        puzzle_id TEXT NOT NULL
      )
    ''');
  }

  // 게임 기록 저장
  Future<void> saveGameRecord(GameRecord record) async {
    await _database.insert('game_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 모든 게임 기록 조회
  Future<List<GameRecord>> getAllGameRecords() async {
    final List<Map<String, dynamic>> maps = await _database.query('game_records', orderBy: 'completed_at DESC');
    return List.generate(maps.length, (i) => GameRecord.fromMap(maps[i]));
  }

  // 난이도별 게임 기록 조회
  Future<List<GameRecord>> getGameRecordsByDifficulty(String difficulty) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'game_records',
      where: 'difficulty = ?',
      whereArgs: [difficulty],
      orderBy: 'elapsed_seconds ASC',
    );
    return List.generate(maps.length, (i) => GameRecord.fromMap(maps[i]));
  }

  // 난이도별 최고 기록 조회
  Future<GameRecord?> getBestRecordByDifficulty(String difficulty) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'game_records',
      where: 'difficulty = ?',
      whereArgs: [difficulty],
      orderBy: 'elapsed_seconds ASC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return GameRecord.fromMap(maps.first);
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
