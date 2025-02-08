// utils/app_localizations.dart

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'ChesSudoku',
      'subtitle': 'A unique blend of Chess and Sudoku',
      'newGame': 'New Game',
      'continueGame': 'Continue Game',
      'records': 'Records',
      'howToPlay': 'How to Play',
      'settings': 'Settings',
      'language': 'Language',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'selectDifficulty': 'Select Difficulty',
      'memo': 'Memo',
      'check': 'Check',
      'undo': 'Undo',
      'reset': 'Reset',
      'pause': 'Pause',
      'resume': 'Resume',
      'complete': 'Complete',
      'time': 'Time',
      'hintsUsed': 'Hints Used',
      'difficulty': 'Difficulty',
      'continue': 'Continue',
      'cancel': 'Cancel',
    },
    'ko': {
      'appName': '체스도쿠',
      'subtitle': '체스와 스도쿠의 독특한 만남',
      'newGame': '새 게임',
      'continueGame': '이어하기',
      'records': '기록실',
      'howToPlay': '게임 방법',
      'settings': '설정',
      'language': '언어',
      'easy': '쉬움',
      'medium': '보통',
      'hard': '어려움',
      'selectDifficulty': '난이도 선택',
      'memo': '메모',
      'check': '확인',
      'undo': '되돌리기',
      'reset': '초기화',
      'pause': '일시정지',
      'resume': '재개',
      'complete': '완료',
      'time': '시간',
      'hintsUsed': '힌트 사용',
      'difficulty': '난이도',
      'continue': '계속하기',
      'cancel': '취소',
    },
  };

  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get subtitle => _localizedValues[locale.languageCode]!['subtitle']!;
  String get newGame => _localizedValues[locale.languageCode]!['newGame']!;
  String get continueGame => _localizedValues[locale.languageCode]!['continueGame']!;
  String get records => _localizedValues[locale.languageCode]!['records']!;
  String get howToPlay => _localizedValues[locale.languageCode]!['howToPlay']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
