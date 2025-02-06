import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChanceManager {
  static const int MAX_CHANCES = 5;
  static const Duration RECHARGE_INTERVAL = Duration(hours: 2);

  final SharedPreferences _prefs;
  Timer? _timer;
  final Function(int chances, Duration? nextRecharge)? _updateCallback;

  // Keys for SharedPreferences
  static const String _chancesKey = 'game_chances';
  static const String _lastUpdateKey = 'last_chance_update';
  static const String _validationKey = 'chance_validation';
  static const String _deviceIdKey = 'device_id';

  ChanceManager(this._prefs, {Function(int chances, Duration? nextRecharge)? updateCallback})
    : _updateCallback = updateCallback {
    _initializeDevice();
    _startTimer();
  }

  // 디바이스 ID 초기화 (앱 설치시 한번만 생성)
  Future<void> _initializeDevice() async {
    if (!_prefs.containsKey(_deviceIdKey)) {
      final deviceId = DateTime.now().toIso8601String() + DateTime.now().millisecondsSinceEpoch.toString();
      await _prefs.setString(_deviceIdKey, deviceId);

      // 최초 설치시 기회 초기화
      await _initializeChances();
    }
    _validateChances();
  }

  // 기회 데이터 초기화
  Future<void> _initializeChances() async {
    await _prefs.setInt(_chancesKey, MAX_CHANCES);
    await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    await _updateValidation();
  }

  // 검증 해시 업데이트
  Future<void> _updateValidation() async {
    final deviceId = _prefs.getString(_deviceIdKey) ?? '';
    final chances = _prefs.getInt(_chancesKey)?.toString() ?? '';
    final lastUpdate = _prefs.getString(_lastUpdateKey) ?? '';

    final validationString = '$deviceId:$chances:$lastUpdate';
    final bytes = utf8.encode(validationString);
    final hash = sha256.convert(bytes).toString();

    await _prefs.setString(_validationKey, hash);
  }

  // 데이터 유효성 검증
  bool _validateChances() {
    final deviceId = _prefs.getString(_deviceIdKey) ?? '';
    final chances = _prefs.getInt(_chancesKey)?.toString() ?? '';
    final lastUpdate = _prefs.getString(_lastUpdateKey) ?? '';
    final storedHash = _prefs.getString(_validationKey) ?? '';

    final validationString = '$deviceId:$chances:$lastUpdate';
    final bytes = utf8.encode(validationString);
    final hash = sha256.convert(bytes).toString();

    if (hash != storedHash) {
      // 데이터가 조작되었다면 초기화
      _initializeChances();
      return false;
    }
    return true;
  }

  // 현재 남은 기회 조회
  int get currentChances {
    _validateChances();
    return _prefs.getInt(_chancesKey) ?? 0;
  }

  // 다음 충전 시간까지 남은 시간
  Duration? get timeUntilNextRecharge {
    final lastUpdateStr = _prefs.getString(_lastUpdateKey);
    if (lastUpdateStr == null) return null;

    final lastUpdate = DateTime.parse(lastUpdateStr);
    final nextRecharge = lastUpdate.add(RECHARGE_INTERVAL);
    final now = DateTime.now();

    if (now.isAfter(nextRecharge)) return null;
    return nextRecharge.difference(now);
  }

  // 기회 사용
  Future<bool> useChance() async {
    if (!_validateChances()) return false;

    final currentChances = _prefs.getInt(_chancesKey) ?? 0;
    if (currentChances <= 0) return false;

    await _prefs.setInt(_chancesKey, currentChances - 1);
    await _updateValidation();

    _updateCallback?.call(currentChances - 1, timeUntilNextRecharge);
    return true;
  }

  // 기회 추가 (광고 시청 등의 보상)
  Future<bool> addChance() async {
    if (!_validateChances()) return false;

    final currentChances = _prefs.getInt(_chancesKey) ?? 0;
    if (currentChances >= MAX_CHANCES) return false;

    await _prefs.setInt(_chancesKey, currentChances + 1);
    await _updateValidation();

    _updateCallback?.call(currentChances + 1, timeUntilNextRecharge);
    return true;
  }

  // 자동 충전 타이머 시작
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAndRechargeChances();
    });
  }

  // 기회 자동 충전 체크
  Future<void> _checkAndRechargeChances() async {
    if (!_validateChances()) return;

    final lastUpdateStr = _prefs.getString(_lastUpdateKey);
    if (lastUpdateStr == null) return;

    final lastUpdate = DateTime.parse(lastUpdateStr);
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference >= RECHARGE_INTERVAL) {
      final currentChances = _prefs.getInt(_chancesKey) ?? 0;
      if (currentChances < MAX_CHANCES) {
        final newChances = currentChances + 1;
        await _prefs.setInt(_chancesKey, newChances);
        await _prefs.setString(_lastUpdateKey, now.toIso8601String());
        await _updateValidation();

        _updateCallback?.call(newChances, timeUntilNextRecharge);
      }
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
