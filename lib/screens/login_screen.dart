import 'package:chessudoku/providers/authentication_provider.dart';
import 'package:chessudoku/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo and name
                  Text(
                    l10n.appName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(offset: const Offset(2, 2), blurRadius: 3.0, color: Colors.black.withOpacity(0.3)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    l10n.subtitle,
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Guest login button
                  _LoginButton(
                    icon: Icons.person_outline,
                    label: l10n.translate('continueAsGuest'),
                    onPressed:
                        authProvider.isLoading
                            ? null
                            : () {
                              context.read<AuthProvider>().signInAnonymously();
                            },
                  ),

                  const SizedBox(height: 16),

                  // Google login button
                  _LoginButton(
                    icon: Icons.g_mobiledata,
                    label: l10n.translate('continueWithGoogle'),
                    color: Colors.white,
                    textColor: Colors.black87,
                    onPressed:
                        authProvider.isLoading
                            ? null
                            : () {
                              context.read<AuthProvider>().signInWithGoogle();
                            },
                  ),

                  const SizedBox(height: 48),

                  // Chess pieces icons
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('♚', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♝', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♞', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♜', style: TextStyle(color: Colors.white, fontSize: 32)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => launchURL('your-terms-url'),
                        child: const Text('이용약관', style: TextStyle(color: Colors.white70)),
                      ),
                      const Text('|', style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () => launchURL('your-privacy-url'),
                        child: const Text('개인정보처리방침', style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),

                  // Loading indicator
                  if (authProvider.isLoading) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;

  const _LoginButton({required this.icon, required this.label, required this.onPressed, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor ?? Colors.white,
          backgroundColor: color ?? Colors.blue.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          disabledBackgroundColor: (color ?? Colors.blue.shade600).withOpacity(0.6),
          disabledForegroundColor: (textColor ?? Colors.white).withOpacity(0.6),
        ),
      ),
    );
  }
}
