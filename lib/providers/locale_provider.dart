import 'package:chessudoku/services/storage_service.dart';
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  static const Map<String, String> supportedLanguages = {'en': 'English', 'ko': '한국어', 'ja': '日本語'};
  final StorageService _storageService;

  Locale _locale;

  LocaleProvider(this._storageService) : _locale = Locale(_storageService.preferences.getString(_localeKey) ?? 'en');

  Locale get locale => _locale;

  static Future<LocaleProvider> initialize() async {
    final storageService = await StorageService.initialize();
    return LocaleProvider(storageService);
  }

  String getCurrentLanguageName() {
    return supportedLanguages[_locale.languageCode] ?? 'English';
  }

  Future<void> setLocale(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) return;

    await _storageService.preferences.setString(_localeKey, languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
