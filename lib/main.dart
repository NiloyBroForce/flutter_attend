import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/teacher.dart';
import 'screens/student.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Google Sign-In once at startup
  try {
    await GoogleSignIn.instance.initialize(
      serverClientId:
          '508876084635-0d4188u640du41mlj0h3s723fn7eudct.apps.googleusercontent.com',
    );
  } catch (e) {
    debugPrint("GoogleSignIn init error: $e");
  }

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

        if (snapshot.hasData && snapshot.data != null) {
          final email = (snapshot.data!.email ?? '').toLowerCase().trim();
          final emailParts = email.split('@');
          final domain = emailParts.length > 1 ? emailParts[1] : '';

          if (domain == 'student.sust.edu') {
            return const StudentHomeScreen();
          } else if (domain.contains('sust')) {
            return const TeacherHomeScreen();
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
  bool _isLoading = false;

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

  Future<void> _handleSubmit(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      if (_isSignUpMode) {
        await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      }

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userEmail = (currentUser.email ?? '').toLowerCase().trim();
        final domain = userEmail.contains('@') ? userEmail.split('@')[1] : '';

        final isStudent = domain == 'student.sust.edu';
        final isTeacher = domain.contains('sust');

        if (!isStudent && !isTeacher) {
          await _auth.signOut();
          _showSnackBar(
            'Access Denied: "$userEmail" is not an official SUST email.',
          );
        }
      }
    } catch (e) {
      _showSnackBar('Authentication failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Android Google Sign-In
  Future<void> _handleAndroidGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn.instance;

      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
        accessToken: clientAuth.accessToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        final userEmail = (user.email ?? '').toLowerCase().trim();
        final domain = userEmail.contains('@') ? userEmail.split('@')[1] : '';

        final isStudent = domain == 'student.sust.edu';
        final isTeacher = domain.contains('sust');

        if (!isStudent && !isTeacher) {
          await _auth.signOut();
          await googleSignIn.signOut();
          _showSnackBar(
            'Access Denied: "$userEmail" is not an official SUST email.',
          );
        }
      }
    } catch (e) {
      _showSnackBar('Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormScreen(
      isSignUpMode: _isSignUpMode,
      isLoading: _isLoading,
      onSwitchMode: () {
        setState(() => _isSignUpMode = !_isSignUpMode);
      },
      onSubmit: _handleSubmit,
      onAndroidGoogleSignIn: _handleAndroidGoogleSignIn,
    );
  }
}

class AuthFormScreen extends StatefulWidget {
  final bool isSignUpMode;
  final bool isLoading;
  final VoidCallback onSwitchMode;
  final Function(String email, String password) onSubmit;
  final VoidCallback onAndroidGoogleSignIn;

  const AuthFormScreen({
    super.key,
    required this.isSignUpMode,
    required this.isLoading,
    required this.onSwitchMode,
    required this.onSubmit,
    required this.onAndroidGoogleSignIn,
  });

  @override
  State<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends State<AuthFormScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.isSignUpMode ? "Create Account" : "Welcome Back";
    String buttonText = widget.isSignUpMode ? "Sign Up" : "Sign In";
    String toggleText = widget.isSignUpMode
        ? "Already have an account? Sign In"
        : "Don't have an account? Sign Up";

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.blue[400]),
                  const SizedBox(height: 16),
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be 6+ characters'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue[700],
                    ),
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              widget.onSubmit(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                            }
                          },
                    child: widget.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Android Google Sign-In Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: widget.isLoading
                        ? null
                        : widget.onAndroidGoogleSignIn,
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onSwitchMode,
                    child: Text(
                      toggleText,
                      style: TextStyle(color: Colors.blue[300]),
                    ),
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
