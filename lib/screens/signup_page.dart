import 'package:flutter/material.dart';
import 'auth_page.dart';

class SignUpPage extends StatelessWidget {
  final Future<void> Function(String email, String password)? onSignUp;
  final VoidCallback? onNavigateToSignIn;
  final Future<void> Function()? onSignUpWithGoogle;

  const SignUpPage({
    super.key,
    this.onSignUp,
    this.onNavigateToSignIn,
    this.onSignUpWithGoogle,
  });

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      headerIcon: Icons.person_add_alt_1_rounded,
      headerIconGradient: const [Color(0xFF7C3AED), Color(0xFF5B21B6)],
      headerIconGlow: const Color(0xFF7C3AED),
      title: 'Create Account',
      smalltitle: 'Register with your official SUST email address',
      topGlowColor: const Color(0xFF7C3AED),
      bottomGlowColor: const Color(0xFF2563EB),
      glowTop: true,
      borderColor: const Color(0xFF8B5CF6),
      submitButtonText: 'Sign Up',
      submitButtonGradient: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
      submitButtonGlow: const Color(0xFF7C3AED),
      googleText: 'Sign up with Google',
      footerText: 'Already have an account? ',
      linkText: 'Sign In',
      linkColor: const Color(0xFF8B5CF6),
      message: 'Please fill in all details',
      onSubmit: onSignUp,
      onGoogleAuth: onSignUpWithGoogle,
      linkTap: onNavigateToSignIn,
    );
  }
}
