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

    void launchURL(String url) async {
      try {
        await launchUrl(Uri.parse(url));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.translate('cannotOpenUrl'))));
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
                  title: l10n.translate('account'),
                  children: [
                    ListTile(
                      title: Text(l10n.translate('deleteAccount')),
                      subtitle: Text(l10n.translate('deleteAccountMessage')),
                      trailing: const Icon(Icons.delete_forever, color: Colors.red),
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                    ListTile(
                      title: Text(l10n.translate('logout')),
                      trailing: const Icon(Icons.logout),
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const Divider(),
                _SettingsSection(
                  title: l10n.translate('termsAndPolicies'),
                  children: [
                    ListTile(
                      title: Text(l10n.translate('termsOfService')),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => launchURL(AppConstants.termsUrl),
                    ),
                    ListTile(
                      title: Text(l10n.translate('privacyPolicy')),
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.translate('deleteAccount')),
            content: Text(l10n.translate('deleteAccountConfirm')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.translate('cancel'))),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().deleteAccount();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('${l10n.translate('deleteAccountFailed')}$e')));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(l10n.translate('delete')),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.translate('logout')),
            content: Text(l10n.translate('logoutConfirm')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.translate('cancel'))),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('${l10n.translate('logoutFailed')}$e')));
                    }
                  }
                },
                child: Text(l10n.translate('logout')),
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
