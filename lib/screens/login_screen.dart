// screens/login_screen.dart

import 'package:chessudoku/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // 로고 또는 앱 이름
                  Text(
                    'ChesSudoku',
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
                    'A unique blend of Chess and Sudoku',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // 게스트 로그인 버튼
                  _LoginButton(
                    icon: Icons.person_outline,
                    label: 'Continue as Guest',
                    onPressed: () {
                      context.read<AuthProvider>().signInAnonymously();
                    },
                  ),

                  const SizedBox(height: 16),

                  // 구글 로그인 버튼
                  _LoginButton(
                    icon: Icons.g_mobiledata,
                    label: 'Continue with Google',
                    color: Colors.white,
                    textColor: Colors.black87,
                    onPressed: () {
                      context.read<AuthProvider>().signInWithGoogle();
                    },
                  ),

                  const SizedBox(height: 48),

                  // 체스 기물 아이콘들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('♚', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♝', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♞', style: TextStyle(color: Colors.white, fontSize: 32)),
                      SizedBox(width: 16),
                      Text('♜', style: TextStyle(color: Colors.white, fontSize: 32)),
                    ],
                  ),
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
  final VoidCallback onPressed;
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
        ),
      ),
    );
  }
}
