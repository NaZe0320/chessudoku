// utils/app_localizations.dart

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
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
      'warning': 'Warning',
      'warningMessage': 'Starting a new game will delete your saved progress.',
      'noChances': 'No Chances Left',
      'watchAd': 'Watch Ad',
      'watchAdMessage': 'Would you like to watch a video ad to get an extra chance?',
      'nextChance': 'Next free chance in:',
      'resetBoard': 'Reset Board',
      'resetMessage': 'This will clear all your progress and restore the board to its initial state.',
      'puzzleCompleted': 'Puzzle Completed!',
      'noRecords': 'No records yet',
      'noMoreRecords': 'No more records',
      'loading': 'Loading...',
      'errorLoading': 'Error loading records:',
      'loginRequired': 'Please login to view records',
      'chanceAddedSuccess': 'Chance added successfully!',
      'adViewingFailed': 'Failed to complete ad viewing. Please try again.',
      'adShowFailed': 'Failed to show ad. Please try again.',
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
      'resume': '계속하기',
      'complete': '완료',
      'time': '시간',
      'hintsUsed': '힌트 사용',
      'difficulty': '난이도',
      'continue': '계속',
      'cancel': '취소',
      'warning': '경고',
      'warningMessage': '새 게임을 시작하면 저장된 진행 상황이 삭제됩니다.',
      'noChances': '기회가 없습니다',
      'watchAd': '광고 보기',
      'watchAdMessage': '광고를 시청하고 추가 기회를 받으시겠습니까?',
      'nextChance': '다음 무료 기회까지:',
      'resetBoard': '보드 초기화',
      'resetMessage': '모든 진행 상황이 초기화됩니다.',
      'puzzleCompleted': '퍼즐 완료!',
      'noRecords': '기록이 없습니다',
      'noMoreRecords': '더 이상 기록이 없습니다',
      'loading': '로딩 중...',
      'errorLoading': '기록 로딩 오류:',
      'loginRequired': '기록을 보려면 로그인이 필요합니다',
      'chanceAddedSuccess': '기회가 추가되었습니다!',
      'adViewingFailed': '광고 시청을 완료하지 못했습니다. 다시 시도해주세요.',
      'adShowFailed': '광고를 표시할 수 없습니다. 다시 시도해주세요.',
    },
    'ja': {
      'appName': 'チェス数独',
      'subtitle': 'チェスと数独の独特な出会い',
      'newGame': '新しいゲーム',
      'continueGame': '続ける',
      'records': '記録',
      'howToPlay': '遊び方',
      'settings': '設定',
      'language': '言語',
      'easy': '易しい',
      'medium': '普通',
      'hard': '難しい',
      'selectDifficulty': '難易度選択',
      'memo': 'メモ',
      'check': '確認',
      'undo': '元に戻す',
      'reset': 'リセット',
      'pause': '一時停止',
      'resume': '再開',
      'complete': '完了',
      'time': '時間',
      'hintsUsed': 'ヒント使用',
      'difficulty': '難易度',
      'continue': '続ける',
      'cancel': 'キャンセル',
      'warning': '警告',
      'warningMessage': '新しいゲームを始めると、保存された進行状況は削除されます。',
      'noChances': 'チャンスがありません',
      'watchAd': '広告を見る',
      'watchAdMessage': '広告を視聴して追加チャンスを獲得しますか？',
      'nextChance': '次の無料チャンスまで：',
      'resetBoard': 'ボードリセット',
      'resetMessage': 'すべての進行状況が初期化されます。',
      'puzzleCompleted': 'パズル完成！',
      'noRecords': '記録がありません',
      'noMoreRecords': 'これ以上の記録はありません',
      'loading': '読み込み中...',
      'errorLoading': '記録の読み込みエラー：',
      'loginRequired': '記録を見るにはログインが必要です',
      'chanceAddedSuccess': 'チャンスが追加されました！',
      'adViewingFailed': '広告視聴を完了できませんでした。もう一度お試しください。',
      'adShowFailed': '広告を表示できません。もう一度お試しください。',
    },
  };

  String translate(String key) {
    if (!_localizedValues.containsKey(locale.languageCode) ||
        !_localizedValues[locale.languageCode]!.containsKey(key)) {
      // 번역이 없을 경우 영어를 폴백으로 사용
      return _localizedValues['en']![key] ?? key;
    }
    return _localizedValues[locale.languageCode]![key]!;
  }

  // 자주 사용되는 키들은 편의를 위해 getter로 제공
  String get appName => translate('appName');
  String get subtitle => translate('subtitle');
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko', 'ja'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
