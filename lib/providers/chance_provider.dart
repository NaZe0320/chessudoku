import 'dart:async';

import 'package:chessudoku/models/chance.dart';
import 'package:chessudoku/services/chance_service.dart';
import 'package:flutter/material.dart';

class ChanceProvider extends ChangeNotifier {
  final ChanceService _chanceService;
  final String _userId;

  Chance? _chance;
  Timer? _timer;
  bool _isInitialized = false;
  Duration? _remainingTime;

  ChanceProvider(this._userId, this._chanceService) {
    _initialize();
  }

  bool get isInitialized => _isInitialized;
  int get currentChances => _chance?.currentChances ?? 0;
  Duration? get nextRecharge => _remainingTime;

  Future<void> _initialize() async {
    // 초기 데이터 로드
    _chance = await _chanceService.getChance(_userId);
    _updateRemainingTime();
    _isInitialized = true;
    notifyListeners();

    // 실시간 업데이트 구독
    _chanceService.chanceStream(_userId).listen((chance) {
      _chance = chance;
      _updateRemainingTime();
      notifyListeners();
    });

    // 타이머 시작
    _startTimer();
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

    final updatedChance = await _chanceService.checkAndRechargeChances(_userId);
    if (updatedChance != null) {
      _chance = updatedChance;
      _updateRemainingTime();
      notifyListeners();
    }
  }

  Future<bool> useChance() async {
    if (_userId.isEmpty) return false;
    final success = await _chanceService.useChance(_userId);
    if (success) {
      _chance = await _chanceService.getChance(_userId);
      _updateRemainingTime();
      notifyListeners();
    }
    return success;
  }

  Future<bool> addChance() async {
    if (_userId.isEmpty) return false;
    final success = await _chanceService.addChance(_userId);
    if (success) {
      _chance = await _chanceService.getChance(_userId);
      _updateRemainingTime();
      notifyListeners();
    }
    return success;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
