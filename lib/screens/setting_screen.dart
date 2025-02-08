// screens/settings_screen.dart

import 'package:chessudoku/widgets/common/banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chessudoku/providers/locale_provider.dart';
import 'package:chessudoku/utils/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        spacing: 4,
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text(localizations.language),
                  trailing: Consumer<LocaleProvider>(
                    builder:
                        (context, provider, child) => DropdownButton<String>(
                          value: provider.locale.languageCode,
                          items:
                              LocaleProvider.supportedLanguages.entries.map((entry) {
                                return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                              }).toList(),
                          onChanged: (String? languageCode) {
                            if (languageCode != null) {
                              provider.setLocale(languageCode);
                            }
                          },
                        ),
                  ),
                ),
                // 여기에 다른 설정 항목들을 추가할 수 있습니다
              ],
            ),
          ),
          BannerAdWidget(),
        ],
      ),
    );
  }
}
