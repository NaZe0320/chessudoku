import 'package:chessudoku/main.dart';
import 'package:chessudoku/providers/authentication_provider.dart';
import 'package:chessudoku/widgets/common/banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chessudoku/providers/locale_provider.dart';
import 'package:chessudoku/utils/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();

    void launchURL(String url) async {
      try {
        await launchUrl(Uri.parse(url));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL을 열 수 없습니다.')));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _SettingsSection(
                  title: l10n.translate('language'),
                  children: [
                    Consumer<LocaleProvider>(
                      builder:
                          (context, provider, child) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: DropdownButtonFormField<String>(
                              value: provider.locale.languageCode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              items:
                                  LocaleProvider.supportedLanguages.entries.map((entry) {
                                    return DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value, style: const TextStyle(fontSize: 16)),
                                    );
                                  }).toList(),
                              onChanged: (String? languageCode) {
                                if (languageCode != null) {
                                  provider.setLocale(languageCode);
                                }
                              },
                            ),
                          ),
                    ),
                  ],
                ),
                const Divider(),
                _SettingsSection(
                  title: '계정',
                  children: [
                    ListTile(
                      title: const Text('계정 삭제'),
                      subtitle: const Text('모든 게임 데이터가 영구적으로 삭제됩니다'),
                      trailing: const Icon(Icons.delete_forever, color: Colors.red),
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                    ListTile(
                      title: const Text('로그아웃'),
                      trailing: const Icon(Icons.logout),
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const Divider(),
                _SettingsSection(
                  title: '약관 및 정책',
                  children: [
                    ListTile(
                      title: const Text('이용약관'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => launchURL(AppConstants.termsUrl),
                    ),
                    ListTile(
                      title: const Text('개인정보처리방침'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => launchURL(AppConstants.privacyUrl),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('계정 삭제'),
            content: const Text('정말로 계정을 삭제하시겠습니까?\n모든 데이터가 영구적으로 삭제됩니다.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().deleteAccount();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('계정 삭제 실패: $e')));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말로 로그아웃 하시겠습니까?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그아웃 실패: $e')));
                    }
                  }
                },
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
        ),
        ...children,
      ],
    );
  }
}
