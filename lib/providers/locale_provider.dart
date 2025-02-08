import 'package:chessudoku/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  final StorageService _storageService;

  Locale _locale;

  LocaleProvider(this._storageService) : _locale = Locale(_storageService.preferences.getString(_localeKey) ?? 'en');

  Locale get locale => _locale;

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ko': '한국어',
    // 여기에 추가 언어를 넣을 수 있습니다
  };

  Future<void> setLocale(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) return;

    await _storageService.preferences.setString(_localeKey, languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
