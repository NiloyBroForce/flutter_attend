
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/teacher.dart';
import 'screens/student.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'screens/signin_page.dart';
import 'screens/signup_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Attendance',
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user != null) {
          final userEmail = (user.email ?? '').toLowerCase().trim();
          final domain = userEmail.contains('@') ? userEmail.split('@')[1] : '';
          final isStudent = domain == 'student.sust.edu';
          final isTeacher = domain.contains('sust') && !isStudent;
          if (isStudent) {
            return const StudentHomeScreen();
          } else if (isTeacher) {
            return const TeacherHomeScreen();
          } else {
            // Unrecognized domain - sign out and force login screen
            FirebaseAuth.instance.signOut();
            return const LoginPage();
          }
        }
        return const LoginPage();
      },
    );
  }
}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSignUpMode = false;

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
  Future<bool> _validateUserDomain(User currentUser) async {
    final userEmail = (currentUser.email ?? '').toLowerCase().trim();
    final domain = userEmail.contains('@') ? userEmail.split('@')[1] : '';
    final isStudent = domain == 'student.sust.edu';
    final isTeacher = domain.contains('sust');
    if (!isStudent && !isTeacher) {
      await _auth.signOut();
      _showSnackBar(
        'Access Denied: "$userEmail" is not an official SUST email.',
      );
      return false;
    }
    return true;
  }
  Future<void> _handleSignIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _validateUserDomain(currentUser);
      }
    } catch (e) {
      _showSnackBar('Authentication failed: ${e.toString()}');
      rethrow; // Pass error back to UI so loading state can reset cleanly
    }
  }
  Future<void> _handleSignUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _validateUserDomain(currentUser);
      }
    } catch (e) {
      _showSnackBar('Registration failed: ${e.toString()}');
      rethrow;
    }
  }
  Future<void> _handleAndroidGoogleSignIn() async {
    try {
       final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '508876084635-0d4188u640du41mlj0h3s723fn7eudct.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      // Validate email domain after Google Sign-In
      if (userCredential.user != null) {
        await _validateUserDomain(userCredential.user!);
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      _showSnackBar('Google Sign-In failed: ${e.toString()}');
    }
  }
   @override
  Widget build(BuildContext context) {
    if (_isSignUpMode) {
      return SignUpPage(
        onSignUp: (email, password) => _handleSignUp(email, password),
        onNavigateToSignIn: () {
          setState(() => _isSignUpMode = false);
        },
      onSignUpWithGoogle: () => _handleAndroidGoogleSignIn(),

      );
    }
    return SignInPage(
      onSignIn: (email, password) => _handleSignIn(email, password),
      onNavigateToSignUp: () {
        setState(() => _isSignUpMode = true);
      },
      onSignInWithGoogle: () => _handleAndroidGoogleSignIn(),

    );
  }
}
