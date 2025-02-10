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
      // App general
      'appName': 'ChesSudoku',
      'subtitle': 'A unique blend of Chess and Sudoku',

      // Login screen
      'continueAsGuest': 'Continue as Guest',
      'continueWithGoogle': 'Continue with Google',

      // Main menu
      'newGame': 'New Game',
      'continueGame': 'Continue Game',
      'records': 'Records',
      'howToPlay': 'How to Play',
      'settings': 'Settings',

      // Game difficulties
      'all': 'All',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'selectDifficulty': 'Select Difficulty',
      'difficulty': 'Difficulty',

      // Game controls
      'memo': 'Memo',
      'check': 'Check',
      'undo': 'Undo',
      'reset': 'Reset',
      'pause': 'Pause',
      'resume': 'Resume',
      'time': 'Time',
      'hintsUsed': 'Hints Used',
      'complete': 'Complete',
      'continue': 'Continue',
      'cancel': 'Cancel',

      // Records screen
      'completed': 'Completed',
      'noRecords': 'No records yet',
      'noMoreRecords': 'No more records',
      'loading': 'Loading...',
      'errorLoading': 'Error loading records:',
      'loginRequired': 'Please login to view records',

      // Settings
      'language': 'Language',

      // Dialogs
      'warning': 'Warning',
      'warningMessage': 'Starting a new game will delete your saved progress.',
      'noChances': 'No Chances Left',
      'watchAd': 'Watch Ad',
      'watchAdMessage': 'Would you like to watch a video ad to get an extra chance?',
      'nextChance': 'Next free chance in:',
      'resetBoard': 'Reset Board',
      'resetMessage': 'This will clear all your progress and restore the board to its initial state.',
      'puzzleCompleted': 'Puzzle Completed!',

      // Messages
      'chanceAddedSuccess': 'Chance added successfully!',
      'adViewingFailed': 'Failed to complete ad viewing. Please try again.',
      'adShowFailed': 'Failed to show ad. Please try again.',

      'gamePaused': 'Game Paused',
      'resumeGame': 'Resume Game',

      'noChecksRemaining': 'No Checks Remaining',
      'watchAdForChecks': 'Would you like to watch an ad to recharge 3 checks?',

      'allInputsCorrect': 'All inputs are correct!',
      'solutionHasErrors': 'There are some errors in your solution. Use check feature to find them.',
      'checksRechargedSuccess': 'Checks recharged successfully!',
      'failedToRechargeChecks': 'Failed to recharge checks. Please try again.',

      'account': 'Account',
      'deleteAccount': 'Delete Account',
      'deleteAccountMessage': 'All game data will be permanently deleted',
      'deleteAccountConfirm': 'Are you sure you want to delete your account?\nAll data will be permanently deleted.',
      'delete': 'Delete',
      'logout': 'Logout',
      'logoutConfirm': 'Are you sure you want to logout?',
      'termsAndPolicies': 'Terms and Policies',
      'termsOfService': 'Terms of Service',
      'privacyPolicy': 'Privacy Policy',
      'cannotOpenUrl': 'Cannot open URL',
      'deleteAccountFailed': 'Failed to delete account: ',
      'logoutFailed': 'Failed to logout: ',

      'ratePuzzle': "Rate this Puzzle's Difficulty",
      'addComment': 'Add a comment (optional)',

      // 튜토리얼
      'howToPlayTitle': 'How to Play',
      'basicRules': 'Basic Rules',
      'sudokuRulesTitle': 'Sudoku Rules',
      'sudokuRulesContent': 'Fill the 9×9 grid with numbers 1-9, ensuring each number appears:',
      'sudokuRule1': 'Once in each row',
      'sudokuRule2': 'Once in each column',
      'sudokuRule3': 'Once in each 3×3 box',
      'chessTwistTitle': 'Chess Twist',
      'chessTwistContent': 'Chess pieces on the board add special rules:',
      'chessTwistRule1': 'Numbers in cells affected by chess pieces must be unique',
      'chessTwistRule2': 'Chess pieces cannot move but affect cells according to their movement patterns',
      'chessTwistRule3': 'Multiple chess pieces can affect the same cell',
      'chessPieces': 'Chess Pieces',
      'kingTitle': 'King',
      'kingDescription': 'Numbers in all adjacent cells (including diagonals) must be different.',
      'bishopTitle': 'Bishop',
      'bishopDescription': 'Numbers along each diagonal line must be different until blocked by another piece.',
      'knightTitle': 'Knight',
      'knightDescription': 'Numbers in all cells reachable by L-shaped moves must be different.',
      'rookTitle': 'Rook',
      'rookDescription':
          'Numbers along horizontal and vertical lines must be different until blocked by another piece.',
      'selectInputTitle': 'Select & Input',
      'selectInputRule1': 'Tap a cell to select it',
      'selectInputRule2': 'Use the number pad to input numbers',
      'selectInputRule3': 'Tap the same number to clear the cell',
      'memoModeTitle': 'Memo Mode',
      'memoModeRule1': 'Toggle memo mode to take notes',
      'memoModeRule2': 'Use numbers to add/remove candidates',
      'memoModeRule3': 'Helpful for tracking possibilities',
      'checkFeatureTitle': 'Check Feature',
      'checkFeatureRule1': 'Use check button to verify your progress',
      'checkFeatureRule2': 'Wrong numbers will be highlighted in red',
      'checkFeatureRule3': 'Limited checks available per puzzle',
      'tipsAndStrategies': 'Tips & Strategies',
      'startWithChessTitle': 'Start with Chess Pieces',
      'startWithChessContent':
          'Begin by identifying cells affected by chess pieces. These have additional constraints that can help narrow down possibilities.',
      'traditionalTechTitle': 'Use Traditional Techniques',
      'traditionalTechContent':
          'Standard Sudoku techniques like scanning and elimination still work. Look for cells with the fewest possibilities.',
      'takeNotesTitle': 'Take Notes',
      'takeNotesContent':
          'Use the memo feature to keep track of possible numbers for each cell. Update these as you fill in numbers.',
      'thinkAheadTitle': 'Think Ahead',
      'thinkAheadContent':
          'Consider how placing a number might affect both Sudoku rules and chess piece constraints before making a move.',
      'previous': 'Previous',
      'next': 'Next',
    },

    'ko': {
      // 앱 일반
      'appName': '체스도쿠',
      'subtitle': '체스와 스도쿠의 독특한 만남',

      // 로그인 화면
      'continueAsGuest': '게스트로 계속하기',
      'continueWithGoogle': '구글로 계속하기',

      // 메인 메뉴
      'newGame': '새 게임',
      'continueGame': '이어하기',
      'records': '기록실',
      'howToPlay': '게임 방법',
      'settings': '설정',

      // 게임 난이도
      'all': '전체',
      'easy': '쉬움',
      'medium': '보통',
      'hard': '어려움',
      'selectDifficulty': '난이도 선택',
      'difficulty': '난이도',

      // 게임 컨트롤
      'memo': '메모',
      'check': '확인',
      'undo': '되돌리기',
      'reset': '초기화',
      'pause': '일시정지',
      'resume': '계속하기',
      'time': '시간',
      'hintsUsed': '힌트 사용',
      'complete': '완료',
      'continue': '계속',
      'cancel': '취소',

      // 기록 화면
      'completed': '완료 시간',
      'noRecords': '기록이 없습니다',
      'noMoreRecords': '더 이상 기록이 없습니다',
      'loading': '로딩 중...',
      'errorLoading': '기록 로딩 오류:',
      'loginRequired': '기록을 보려면 로그인이 필요합니다',

      // 설정
      'language': '언어',

      // 다이얼로그
      'warning': '경고',
      'warningMessage': '새 게임을 시작하면 저장된 진행 상황이 삭제됩니다.',
      'noChances': '기회가 없습니다',
      'watchAd': '광고 보기',
      'watchAdMessage': '광고를 시청하고 추가 기회를 받으시겠습니까?',
      'nextChance': '다음 무료 기회까지:',
      'resetBoard': '보드 초기화',
      'resetMessage': '모든 진행 상황이 초기화됩니다.',
      'puzzleCompleted': '퍼즐 완료!',

      // 메시지
      'chanceAddedSuccess': '기회가 추가되었습니다!',
      'adViewingFailed': '광고 시청을 완료하지 못했습니다. 다시 시도해주세요.',
      'adShowFailed': '광고를 표시할 수 없습니다. 다시 시도해주세요.',

      'gamePaused': '게임 일시정지',
      'resumeGame': '게임 재개',

      'noChecksRemaining': '확인 기능 소진',
      'watchAdForChecks': '광고를 시청하고 확인 기능 3회를 충전하시겠습니까?',

      'allInputsCorrect': '모든 입력이 올바릅니다!',
      'solutionHasErrors': '해답에 오류가 있습니다. 확인 기능을 사용하여 찾아보세요.',
      'checksRechargedSuccess': '확인 기능이 충전되었습니다!',
      'failedToRechargeChecks': '확인 기능 충전에 실패했습니다. 다시 시도해주세요.',

      'account': '계정',
      'deleteAccount': '계정 삭제',
      'deleteAccountMessage': '모든 게임 데이터가 영구적으로 삭제됩니다',
      'deleteAccountConfirm': '정말로 계정을 삭제하시겠습니까?\n모든 데이터가 영구적으로 삭제됩니다.',
      'delete': '삭제',
      'logout': '로그아웃',
      'logoutConfirm': '정말로 로그아웃 하시겠습니까?',
      'termsAndPolicies': '약관 및 정책',
      'termsOfService': '이용약관',
      'privacyPolicy': '개인정보처리방침',
      'cannotOpenUrl': 'URL을 열 수 없습니다',
      'deleteAccountFailed': '계정 삭제 실패: ',
      'logoutFailed': '로그아웃 실패: ',

      'ratePuzzle': '이 퍼즐의 난이도 평가하기',
      'addComment': '코멘트를 추가해주세요(선택)',

      //튜토리얼
      'howToPlayTitle': '게임 방법',
      'basicRules': '기본 규칙',
      'sudokuRulesTitle': '스도쿠 규칙',
      'sudokuRulesContent': '9×9 그리드를 1-9의 숫자로 채우되, 각 숫자는 다음과 같이 배치되어야 합니다:',
      'sudokuRule1': '각 행에 한 번씩',
      'sudokuRule2': '각 열에 한 번씩',
      'sudokuRule3': '각 3×3 박스에 한 번씩',
      'chessTwistTitle': '체스 변형 규칙',
      'chessTwistContent': '보드의 체스 기물들은 다음과 같은 특별한 규칙을 추가합니다:',
      'chessTwistRule1': '체스 기물의 영향을 받는 칸의 숫자는 모두 달라야 합니다',
      'chessTwistRule2': '체스 기물은 이동할 수 없지만 이동 패턴에 따라 다른 칸에 영향을 줍니다',
      'chessTwistRule3': '여러 체스 기물이 같은 칸에 영향을 줄 수 있습니다',
      'chessPieces': '체스 기물',
      'kingTitle': '킹',
      'kingDescription': '인접한 모든 칸(대각선 포함)의 숫자가 달라야 합니다.',
      'bishopTitle': '비숍',
      'bishopDescription': '각 대각선 방향으로 다른 기물에 막힐 때까지의 모든 숫자가 달라야 합니다.',
      'knightTitle': '나이트',
      'knightDescription': 'L자 모양으로 이동 가능한 모든 칸의 숫자가 달라야 합니다.',
      'rookTitle': '룩',
      'rookDescription': '가로와 세로 방향으로 다른 기물에 막힐 때까지의 모든 숫자가 달라야 합니다.',
      'selectInputTitle': '선택 및 입력',
      'selectInputRule1': '칸을 탭하여 선택',
      'selectInputRule2': '숫자 패드로 숫자 입력',
      'selectInputRule3': '같은 숫자를 탭하여 지우기',
      'memoModeTitle': '메모 모드',
      'memoModeRule1': '메모 모드를 켜서 노트 작성',
      'memoModeRule2': '숫자를 사용하여 후보 추가/제거',
      'memoModeRule3': '가능한 숫자 추적에 유용',
      'checkFeatureTitle': '확인 기능',
      'checkFeatureRule1': '확인 버튼으로 진행 상황 검증',
      'checkFeatureRule2': '잘못된 숫자는 빨간색으로 표시',
      'checkFeatureRule3': '퍼즐당 제한된 확인 기회 제공',
      'tipsAndStrategies': '팁과 전략',
      'startWithChessTitle': '체스 기물부터 시작하기',
      'startWithChessContent': '체스 기물의 영향을 받는 칸을 먼저 파악하세요. 이러한 추가 제약 조건은 가능성을 좁히는 데 도움이 됩니다.',
      'traditionalTechTitle': '전통적인 기법 활용',
      'traditionalTechContent': '스캐닝과 제거와 같은 기본적인 스도쿠 기법도 여전히 유효합니다. 가능성이 가장 적은 칸을 찾아보세요.',
      'takeNotesTitle': '메모하기',
      'takeNotesContent': '메모 기능을 사용하여 각 칸에 가능한 숫자를 기록하세요. 숫자를 채워넣으면서 메모를 업데이트하세요.',
      'thinkAheadTitle': '앞서 생각하기',
      'thinkAheadContent': '숫자를 놓기 전에 스도쿠 규칙과 체스 기물 제약 조건이 어떻게 영향을 미칠지 고려하세요.',
      'previous': '이전',
      'next': '다음',
    },

    'ja': {
      // アプリ全般
      'appName': 'チェス数独',
      'subtitle': 'チェスと数独の独特な出会い',

      // ログイン画面
      'continueAsGuest': 'ゲストとして続ける',
      'continueWithGoogle': 'Googleで続ける',

      // メインメニュー
      'newGame': '新しいゲーム',
      'continueGame': '続ける',
      'records': '記録',
      'howToPlay': '遊び方',
      'settings': '設定',

      // 難易度
      'all': '全て',
      'easy': '易しい',
      'medium': '普通',
      'hard': '難しい',
      'selectDifficulty': '難易度選択',
      'difficulty': '難易度',

      // ゲームコントロール
      'memo': 'メモ',
      'check': '確認',
      'undo': '元に戻す',
      'reset': 'リセット',
      'pause': '一時停止',
      'resume': '再開',
      'time': '時間',
      'hintsUsed': 'ヒント使用',
      'complete': '完了',
      'continue': '続ける',
      'cancel': 'キャンセル',

      // 記録画面
      'completed': '完了時間',
      'noRecords': '記録がありません',
      'noMoreRecords': 'これ以上の記録はありません',
      'loading': '読み込み中...',
      'errorLoading': '記録の読み込みエラー：',
      'loginRequired': '記録を見るにはログインが必要です',

      // 設定
      'language': '言語',

      // ダイアログ
      'warning': '警告',
      'warningMessage': '新しいゲームを始めると、保存された進行状況は削除されます。',
      'noChances': 'チャンスがありません',
      'watchAd': '広告を見る',
      'watchAdMessage': '広告を視聴して追加チャンスを獲得しますか？',
      'nextChance': '次の無料チャンスまで：',
      'resetBoard': 'ボードリセット',
      'resetMessage': 'すべての進行状況が初期化されます。',
      'puzzleCompleted': 'パズル完成！',

      // メッセージ
      'chanceAddedSuccess': 'チャンスが追加されました！',
      'adViewingFailed': '広告視聴を完了できませんでした。もう一度お試しください。',
      'adShowFailed': '広告を表示できません。もう一度お試しください。',

      'gamePaused': 'ゲーム一時停止',
      'resumeGame': 'ゲーム再開',

      'noChecksRemaining': 'チェック機能消費',
      'watchAdForChecks': '広告を視聴してチェック機能を3回充電しますか？',

      'allInputsCorrect': 'すべての入力が正しいです！',
      'solutionHasErrors': '解答にエラーがあります。チェック機能を使用して確認してください。',
      'checksRechargedSuccess': 'チェック機能が充電されました！',
      'failedToRechargeChecks': 'チェック機能の充電に失敗しました。もう一度お試しください。',

      'account': 'アカウント',
      'deleteAccount': 'アカウント削除',
      'deleteAccountMessage': 'すべてのゲームデータが完全に削除されます',
      'deleteAccountConfirm': '本当にアカウントを削除しますか？\nすべてのデータが完全に削除されます。',
      'delete': '削除',
      'logout': 'ログアウト',
      'logoutConfirm': '本当にログアウトしますか？',
      'termsAndPolicies': '利用規約とポリシー',
      'termsOfService': '利用規約',
      'privacyPolicy': 'プライバシーポリシー',
      'cannotOpenUrl': 'URLを開けません',
      'deleteAccountFailed': 'アカウント削除に失敗しました: ',
      'logoutFailed': 'ログアウトに失敗しました: ',

      'ratePuzzle': 'このパズルの難易度評価',
      'addComment': 'コメントを追加します（オプション）',

      //튜토리얼
      'howToPlayTitle': '遊び方',
      'basicRules': '基本ルール',
      'sudokuRulesTitle': '数独のルール',
      'sudokuRulesContent': '9×9のグリッドを1-9の数字で埋めます。各数字は：',
      'sudokuRule1': '各行に1回ずつ',
      'sudokuRule2': '各列に1回ずつ',
      'sudokuRule3': '各3×3ボックスに1回ずつ',
      'chessTwistTitle': 'チェスの追加ルール',
      'chessTwistContent': 'ボード上のチェスの駒は特別なルールを追加します：',
      'chessTwistRule1': 'チェスの駒の影響を受けるマスの数字はすべて異なる必要があります',
      'chessTwistRule2': 'チェスの駒は移動できませんが、移動パターンに従って他のマスに影響を与えます',
      'chessTwistRule3': '複数のチェスの駒が同じマスに影響を与えることができます',
      'chessPieces': 'チェスの駒',
      'kingTitle': 'キング',
      'kingDescription': '隣接するすべてのマス（斜めを含む）の数字が異なる必要があります。',
      'bishopTitle': 'ビショップ',
      'bishopDescription': '各斜め方向で、他の駒にブロックされるまでのすべての数字が異なる必要があります。',
      'knightTitle': 'ナイト',
      'knightDescription': 'L字型の移動で到達可能なすべてのマスの数字が異なる必要があります。',
      'rookTitle': 'ルーク',
      'rookDescription': '縦横の方向で、他の駒にブロックされるまでのすべての数字が異なる必要があります。',
      'selectInputTitle': '選択と入力',
      'selectInputRule1': 'マスをタップして選択',
      'selectInputRule2': '数字パッドで数字を入力',
      'selectInputRule3': '同じ数字をタップして消去',
      'memoModeTitle': 'メモモード',
      'memoModeRule1': 'メモモードを切り替えてノートを取る',
      'memoModeRule2': '数字を使用して候補を追加/削除',
      'memoModeRule3': '可能性の追跡に役立ちます',
      'checkFeatureTitle': 'チェック機能',
      'checkFeatureRule1': 'チェックボタンで進行状況を確認',
      'checkFeatureRule2': '間違った数字は赤で表示',
      'checkFeatureRule3': 'パズルごとに制限されたチェック回数',
      'tipsAndStrategies': 'ヒントと戦略',
      'startWithChessTitle': 'チェスの駒から始める',
      'startWithChessContent': 'チェスの駒の影響を受けるマスを特定することから始めます。これらの追加制約は可能性を絞り込むのに役立ちます。',
      'traditionalTechTitle': '従来の技法を使用',
      'traditionalTechContent': 'スキャンや消去などの標準的な数独の技法も有効です。可能性が最も少ないマスを探してください。',
      'takeNotesTitle': 'メモを取る',
      'takeNotesContent': 'メモ機能を使用して、各マスの可能な数字を記録します。数字を埋めながらメモを更新してください。',
      'thinkAheadTitle': '先を考える',
      'thinkAheadContent': '数字を配置する前に、数独のルールとチェスの駒の制約の両方がどのように影響するかを考慮してください。',
      'previous': '前へ',
      'next': '次へ',
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
