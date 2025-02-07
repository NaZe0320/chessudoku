import 'package:chessudoku/services/ad_service.dart';
import 'package:flutter/material.dart';

class AdProvider extends ChangeNotifier {
  final AdService _adService;

  AdProvider(this._adService);

  Future<void> initialize() async {
    await _adService.initialize();
  }

  Future<bool> showRewardedAd() async {
    return await _adService.showRewardedAd();
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }
}
