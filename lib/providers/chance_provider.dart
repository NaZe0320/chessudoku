import 'dart:async';

import 'package:chessudoku/models/chance.dart';
import 'package:chessudoku/services/chance_service.dart';
import 'package:flutter/material.dart';

class ChanceProvider extends ChangeNotifier {
  final ChanceService _chanceService;
  final String _userId;
  bool _disposed = false;

  Chance? _chance;
  Timer? _timer;
  bool _isInitialized = false;
  Duration? _remainingTime;
  StreamSubscription? _chanceSubscription;

  ChanceProvider(this._userId, this._chanceService) {
    if (_userId.isNotEmpty) {
      _initialize();
    } else {
      _chance = Chance.initial();
      _isInitialized = true;
    }
  }

  bool get isInitialized => _isInitialized;
  int get currentChances => _chance?.currentChances ?? 0;
  Duration? get nextRecharge => _remainingTime;

  Future<void> _initialize() async {
    if (_userId.isEmpty) return;

    try {
      // 초기 데이터 로드
      _chance = await _chanceService.getChance(_userId);
      _updateRemainingTime();
      _isInitialized = true;
      if (!_disposed) notifyListeners();

      // 실시간 업데이트 구독
      _chanceSubscription = _chanceService.chanceStream(_userId).listen((chance) {
        _chance = chance;
        _updateRemainingTime();
        if (!_disposed) notifyListeners();
      });

      // 타이머 시작
      _startTimer();
    } catch (e) {
      print('Error initializing ChanceProvider: $e');
      // 에러 발생시 기본값으로 초기화
      _chance = Chance.initial();
      _isInitialized = true;
      if (!_disposed) notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
      if (_remainingTime != null) {
        notifyListeners();
      } else {
        _checkAndRechargeChances();
      }
    });
  }

  void _updateRemainingTime() {
    if (_chance == null) return;

    final nextRecharge = _chance!.lastUpdateTime.add(Chance.rechargeInterval);
    final now = DateTime.now();

    if (now.isAfter(nextRecharge)) {
      _remainingTime = null;
    } else {
      _remainingTime = nextRecharge.difference(now);
    }
  }

  Future<void> _checkAndRechargeChances() async {
    if (_userId.isEmpty) return;

    try {
      final updatedChance = await _chanceService.checkAndRechargeChances(_userId);
      if (updatedChance != null) {
        _chance = updatedChance;
        _updateRemainingTime();
        if (!_disposed) notifyListeners();
      }
    } catch (e) {
      print('Error checking and recharging chances: $e');
    }
  }

  Future<bool> useChance() async {
    if (_userId.isEmpty) return false;
    try {
      final success = await _chanceService.useChance(_userId);
      if (success) {
        _chance = await _chanceService.getChance(_userId);
        _updateRemainingTime();
        if (!_disposed) notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error using chance: $e');
      return false;
    }
  }

  Future<bool> addChance() async {
    if (_userId.isEmpty) return false;
    try {
      final success = await _chanceService.addChance(_userId);
      if (success) {
        _chance = await _chanceService.getChance(_userId);
        _updateRemainingTime();
        if (!_disposed) notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error adding chance: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _chanceSubscription?.cancel();
    super.dispose();
  }
}
