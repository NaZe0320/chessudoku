import 'package:chessudoku/models/chance_manager.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ChanceProvider extends ChangeNotifier {
  late final ChanceManager _chanceManager;
  int _currentChances = 5;
  Duration? _nextRecharge;
  bool _isInitialized = false;

  int get currentChances => _currentChances;
  Duration? get nextRecharge => _nextRecharge;
  bool get isInitialized => _isInitialized;

  ChanceProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _chanceManager = ChanceManager(prefs, updateCallback: _handleChanceUpdate);
    _currentChances = _chanceManager.currentChances;
    _nextRecharge = _chanceManager.timeUntilNextRecharge;
    _isInitialized = true;
    notifyListeners();
  }

  void _handleChanceUpdate(int chances, Duration? nextRecharge) {
    _currentChances = chances;
    _nextRecharge = nextRecharge;
    notifyListeners();
  }

  Future<bool> useChance() async {
    final result = await _chanceManager.useChance();
    if (result) {
      _currentChances = _chanceManager.currentChances;
      _nextRecharge = _chanceManager.timeUntilNextRecharge;
      notifyListeners();
    }
    return result;
  }

  Future<bool> addChance() async {
    final result = await _chanceManager.addChance();
    if (result) {
      _currentChances = _chanceManager.currentChances;
      _nextRecharge = _chanceManager.timeUntilNextRecharge;
      notifyListeners();
    }
    return result;
  }

  @override
  void dispose() {
    _chanceManager.dispose();
    super.dispose();
  }
}
