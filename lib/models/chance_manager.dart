import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ChanceManager {
  static const String _chancesKey = 'pawn_chances';
  static const String _lastUpdateKey = 'last_chance_update';
  static const int maxChances = 5;
  static const Duration rechargeDuration = Duration(hours: 3);

  final SharedPreferences _prefs;
  Timer? _timer;
  Function(int chances, Duration? nextRecharge)? _onUpdate;

  ChanceManager(this._prefs) {
    _initializeChances();
    _startTimer();
  }

  Future<bool> addChance() async {
    await _processElapsedTime();
    final currentChances = _prefs.getInt(_chancesKey) ?? 0;

    if (currentChances < maxChances) {
      await _prefs.setInt(_chancesKey, currentChances + 1);
      _updateCallback();
      return true;
    }
    return false;
  }

  Future<bool> useChance() async {
    await _processElapsedTime();
    final currentChances = _prefs.getInt(_chancesKey) ?? 0;

    if (currentChances > 0) {
      await _prefs.setInt(_chancesKey, currentChances - 1);
      _updateCallback();
      return true;
    }
    return false;
  }

  void setUpdateCallback(Function(int chances, Duration? nextRecharge) callback) {
    _onUpdate = callback;
    _updateCallback();
  }

  Future<void> _initializeChances() async {
    if (!_prefs.containsKey(_chancesKey)) {
      await _prefs.setInt(_chancesKey, maxChances);
      await _prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    }
    _processElapsedTime();
  }

  Future<void> _processElapsedTime() async {
    final lastUpdate = DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt(_lastUpdateKey) ?? DateTime.now().millisecondsSinceEpoch,
    );
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inSeconds > 0) {
      final currentChances = _prefs.getInt(_chancesKey) ?? maxChances;
      final earnedChances = difference.inHours ~/ 3;

      if (earnedChances > 0) {
        final newChances = (currentChances + earnedChances).clamp(0, maxChances);
        await _prefs.setInt(_chancesKey, newChances);

        // Update last update time, accounting for unused time
        final usedTime = Duration(hours: earnedChances * 3);
        final newLastUpdate = lastUpdate.add(usedTime);
        await _prefs.setInt(_lastUpdateKey, newLastUpdate.millisecondsSinceEpoch);
      }
    }
    _updateCallback();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCallback();
    });
  }

  void _updateCallback() {
    if (_onUpdate != null) {
      final chances = _prefs.getInt(_chancesKey) ?? maxChances;
      final lastUpdate = DateTime.fromMillisecondsSinceEpoch(
        _prefs.getInt(_lastUpdateKey) ?? DateTime.now().millisecondsSinceEpoch,
      );

      if (chances < maxChances) {
        final nextRecharge = rechargeDuration - DateTime.now().difference(lastUpdate);
        _onUpdate!(chances, nextRecharge.isNegative ? Duration.zero : nextRecharge);
      } else {
        _onUpdate!(chances, null);
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> reset() async {
    await _prefs.setInt(_chancesKey, maxChances);
    await _prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    _updateCallback();
  }
}
