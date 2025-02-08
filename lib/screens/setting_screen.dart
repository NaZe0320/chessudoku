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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
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
              ],
            ),
          ),
          BannerAdWidget(),
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
