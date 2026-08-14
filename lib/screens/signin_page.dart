import 'package:flutter/material.dart';
import 'auth_page.dart';

class SignInPage extends StatelessWidget {
  final Future<void> Function(String email, String password)? onSignIn;
  final VoidCallback? onNavigateToSignUp;
  final Future<void> Function()? onSignInWithGoogle;

  const SignInPage({
    super.key,
    this.onSignIn,
    this.onNavigateToSignUp,
    this.onSignInWithGoogle,
  });

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      headerIcon: Icons.school_rounded,
      headerIconGradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      headerIconGlow: const Color(0xFF3B82F6),
      title: 'Welcome Back',
      smalltitle: 'Sign in to your SUST account to continue',
      topGlowColor: const Color(0xFF2563EB),
      bottomGlowColor: const Color(0xFF7C3AED),
      glowTop: false,
      borderColor: const Color(0xFF3B82F6),
      submitButtonText: 'Sign In',
      submitButtonGradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      submitButtonGlow: const Color(0xFF2563EB),
      googleText: 'Sign in with Google',
      footerText: "Don't have an account? ",
      linkText: 'Sign Up',
      linkColor: const Color(0xFF3B82F6),
      message: 'Please enter your credentials',
      onSubmit: onSignIn,
      onGoogleAuth: onSignInWithGoogle,
      linkTap: onNavigateToSignUp,
    );
  }
}
