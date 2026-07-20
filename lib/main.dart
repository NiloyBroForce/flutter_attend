import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/teacher.dart';
import 'screens/student.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Attendance',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget{
  @override
  _LoginPageState createState()=>_LoginPageState();
}

class _LoginPageState extends State<LoginPage>{

final FirebaseAuth _auth=FirebaseAuth.instance;

  bool _isShowingSignUpPage = false;

  Future<void> signOutUser() async {
    await _auth.signOut();
  }

Future<void> _signIn(String email, String password) async {
  try {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    print('Error signing in: $e');
    // ... your SnackBar error handling code ...
  }  
}

Future<void> _signUp(String email, String password) async {
  try {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    print('Error signing up: $e');
    // ... your SnackBar error handling code ...
  }
}
@override
Widget build(BuildContext context) {
    // StreamBuilder evaluates the authentication status asynchronously on every app refresh
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        // 1. App is checking local cache tokens to see if a session exists
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Persistent User Session Found -> Evaluate Role & Return Screen
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          final email = user.email ?? '';

          if (email.endsWith('@student.com')) {
            return StudentHomeScreen();
          } else if (email.endsWith('@teacher.com')) {
            return TeacherHomeScreen();
          }

          // Fallback layout if someone logs in with an unexpected email domain
          return const Scaffold(
            body: Center(child: Text('Unauthorized role pattern.')),
          );
        }

       // 3. Unauthenticated -> Display Auth UI depending on the toggle state
        if (_isShowingSignUpPage) {
          return AuthFormScreen(
            isSignUpMode: true,
            onSwitchMode: () => setState(() => _isShowingSignUpPage = false),
            onSubmit: (email, password) =>
                _signUp(email, password), 
          );
        } else {
          return AuthFormScreen(
            isSignUpMode: false,
            onSwitchMode: () => setState(() => _isShowingSignUpPage = true),
            onSubmit: (email, password) =>
                _signIn(email, password), 
          );
        }
      },
    );
  }
}
class AuthFormScreen extends StatefulWidget {
  final bool isSignUpMode;
  final VoidCallback onSwitchMode;
  final Function(String email, String password) onSubmit;

  const AuthFormScreen({
    super.key,
    required this.isSignUpMode,
    required this.onSwitchMode,
    required this.onSubmit,
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      }
                    },
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 16),
                    ),
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
