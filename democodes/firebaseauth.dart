import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'firebaserealtimedatabase.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;

class MainNavigationController extends StatefulWidget {
  const MainNavigationController({super.key});

  @override
  State<MainNavigationController> createState() =>
      _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController> {
  // We keep this to toggle between the Sign In and Sign Up views specifically
  bool _isShowingSignUpPage = false;

  // --- Live Firebase Authentication Functions ---
  Future<void> createUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("★★★ Sign Up Success! UID: ${userCredential.user?.uid}");
      // Note: StreamBuilder will see this auth state change and instantly switch the screen for you!
    } on FirebaseAuthException catch (e) {
      print("❌ Sign Up Error: ${e.message}");
      // You can bubble this up to show a snackbar or alert dialog if desired
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("★★★ Sign In Success! UID: ${userCredential.user?.uid}");
    } on FirebaseAuthException catch (e) {
      print("❌ Sign In Error: ${e.message}");
    }
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
    print("★★★ Signed Out Successfully");
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

        // 2. Persistent User Session Found -> Send to your Live CRUD testing console
        if (snapshot.hasData && snapshot.data != null) {
          return DatabaseTestPage(onSignOut: () => signOutUser());
        }

        // 3. Unauthenticated -> Display Auth UI depending on the toggle state
        if (_isShowingSignUpPage) {
          return AuthFormScreen(
            isSignUpMode: true,
            onSwitchMode: () => setState(() => _isShowingSignUpPage = false),
            onSubmit: (email, password) =>
                createUser(email: email, password: password),
          );
        } else {
          return AuthFormScreen(
            isSignUpMode: false,
            onSwitchMode: () => setState(() => _isShowingSignUpPage = true),
            onSubmit: (email, password) =>
                loginUser(email: email, password: password),
          );
        }
      },
    );
  }
}

class DatabaseTestPage extends StatefulWidget {
  final VoidCallback onSignOut;
  const DatabaseTestPage({super.key, required this.onSignOut});

  @override
  State<DatabaseTestPage> createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
  String _consoleOutput = "Ready. Click a button to execute a function...";

  void _log(String message) {
    setState(() {
      _consoleOutput =
          "${DateTime.now().toString().split(' ')[1].substring(0, 8)}: $message";
    });
  }

  Future<void> _safeExecute(
    String operationName,
    Future<void> Function() action,
  ) async {
    _log("Executing $operationName...");
    try {
      await action().timeout(const Duration(seconds: 5));
    } on TimeoutException {
      _log("❌ Error: $operationName timed out!");
    } catch (e) {
      _log("❌ Error in $operationName: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime DB Web Test Platform'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: widget.onSignOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Create Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    await _safeExecute("Create", () async {
                      await DatabaseService().create(
                        path: 'data1',
                        data: "{'name': 'Flutter demo'}",
                      );
                      _log("Created data at 'data1' successfully.");
                    });
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Read Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    await _safeExecute("Read", () async {
                      DataSnapshot? snapshot = await DatabaseService().read(
                        path: 'data1',
                      );
                      if (snapshot != null && snapshot.value != null) {
                        _log("Data found! Value: ${snapshot.value}");
                      } else {
                        _log("Read completed: Path holds no data.");
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    await _safeExecute("Update", () async {
                      await DatabaseService().update(
                        path: 'data1',
                        data: {'name': 'Updated Flutter demo'},
                      );
                      _log("Updated data at 'data1' successfully.");
                    });
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    await _safeExecute("Delete", () async {
                      await DatabaseService().delete(path: 'data1');
                      _log("Deleted data at 'data1' successfully.");
                    });
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  "Output Log:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Text(
                    _consoleOutput,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
