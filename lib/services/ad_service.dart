import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String _rewardedAdUnitId = 'ca-app-pub-3877424348956918/7757087581';
  static const String _bannerAdUnitId = 'ca-app-pub-3877424348956918/9556382279';

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadRewardedAd();
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );
  }

  Future<void> _loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
          },
          onAdFailedToLoad: (error) {
            print('Failed to load rewarded ad: ${error.message}');
            _isRewardedAdReady = false;
          },
        ),
      );
    } catch (e) {
      print('Error loading rewarded ad: $e');
      _isRewardedAdReady = false;
    }
  }

  Future<bool> showRewardedAd() async {
    if (!_isRewardedAdReady) {
      await _loadRewardedAd();
    }

    if (_rewardedAd == null) return false;

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedAdReady = false;
        _loadRewardedAd(); // 다음 광고 미리 로드
        completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedAdReady = false;
        _loadRewardedAd(); // 다음 광고 미리 로드
        completer.complete(false);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        completer.complete(true);
      },
    );

    return completer.future;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
