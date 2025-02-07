import 'dart:convert';
import 'package:chessudoku/models/game_record.dart';
import 'package:chessudoku/models/game_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _gameProgressKey = 'game_progress';

  final SharedPreferences _preferences;
  final FirebaseFirestore _firestore;

  StorageService(this._preferences) : _firestore = FirebaseFirestore.instance;

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    // final database = await _initializeDatabase();
    return StorageService(prefs);
  }

  // 게임 기록 저장
  Future<void> saveGameRecord(GameRecord record, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('records').add(record.toMap());
    } catch (e) {
      print('Error saving game record to Firebase: $e');
      throw Exception('Failed to save game record');
    }
  }

  // 모든 게임 기록 조회 (Firebase)
  Future<List<GameRecord>> getAllGameRecords(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('records')
              .orderBy('completed_at', descending: true)
              .get();

      return snapshot.docs.map((doc) => GameRecord.fromMap({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      print('Error getting game records from Firebase: $e');
      return [];
    }
  }

  // 난이도별 게임 기록 조회 (Firebase)
  Future<List<GameRecord>> getGameRecordsByDifficulty(String userId, String difficulty) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('records')
              .where('difficulty', isEqualTo: difficulty)
              .orderBy('elapsed_seconds', descending: false)
              .get();

      return snapshot.docs.map((doc) => GameRecord.fromMap({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      print('Error getting game records by difficulty from Firebase: $e');
      return [];
    }
  }

  // 난이도별 최고 기록 조회 (Firebase)
  Future<GameRecord?> getBestRecordByDifficulty(String userId, String difficulty) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('records')
              .where('difficulty', isEqualTo: difficulty)
              .orderBy('elapsed_seconds', descending: false)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return null;
      return GameRecord.fromMap({...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
    } catch (e) {
      print('Error getting best record from Firebase: $e');
      return null;
    }
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
