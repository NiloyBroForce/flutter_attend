import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student.dart';
import 'firebase_options.dart';
import 'teacher.dart';


const _emailLinkPrefsKey = 'emailForSignIn';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  String? _linkError;

  @override
  void initState() {
    super.initState();
    _listenForSignInLinks();
  }

  Future<void> _listenForSignInLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) await _completeSignInWithLink(initialUri);
    } catch (_) {
    }

    _linkSub = _appLinks.uriLinkStream.listen(
      _completeSignInWithLink,
      onError: (_) {},
    );
  }

  Future<void> _completeSignInWithLink(Uri uri) async {
    final link = uri.toString();
    final auth = FirebaseAuth.instance;

    if (!auth.isSignInWithEmailLink(link)) return;

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailLinkPrefsKey);

    if (savedEmail == null) {
      setState(() {
        _linkError =
            'This sign-in link was opened on a device that didn\'t request it. ';
      });
      return;
    }

    try {
      await auth.signInWithEmailLink(email: savedEmail, emailLink: link);
      await prefs.remove(_emailLinkPrefsKey);
      if (mounted) setState(() => _linkError = null);
    } on FirebaseAuthException catch (e) {
      setState(() => _linkError = 'Sign-in failed: ${e.message}');
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'android',
      theme: ThemeData(brightness: Brightness.dark),
      home: UI(linkError: _linkError),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UI extends StatelessWidget {
  const UI({super.key, this.linkError});

  final String? linkError;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          final userEmail = user.email ?? ''.toLowerCase().trim();
          final domain = userEmail.contains('@') ? userEmail.split('@')[1] : '';
          final registration = userEmail.contains('@') ? userEmail.split('@')[0] : '';
          final student = domain == 'student.sust.edu';

          if (student) {return StudentScreen(studentEmail: userEmail, studentReg: registration);}
          else{
         return TeacherScreen();
         }
          
        }
        return Login(linkError: linkError);
      },
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key, this.linkError});

  final String? linkError;

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  late final emailcontroller = TextEditingController();
  bool _linkSent = false;
  bool _sending = false;

  Future<void> _sendLink() async {
    final email = emailcontroller.text.trim();
    if (email.isEmpty) return;

    setState(() => _sending = true);
    try {
      await Logic.sendSignInLink(email);
      if (!mounted) return;
      setState(() => _linkSent = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send sign-in link: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 0, 36),
      appBar: AppBar(
        title: Text('Android Attendance'),
        backgroundColor: const Color.fromARGB(255, 0, 13, 71),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(60)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Shahjalal University of Science and Technology',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(204, 255, 255, 255),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.linkError != null) ...[
                  Text(
                    widget.linkError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                ],
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 6,
                  color: const Color.fromRGBO(68, 138, 255, 1),
                  surfaceTintColor: const Color.fromARGB(255, 243, 14, 205),
                  shadowColor: const Color.fromARGB(255, 186, 212, 255),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _linkSent
                          ? 'Check your email and open the sign-in link on this device.'
                          : 'Enter your email to receive a sign-in link',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(221, 231, 218, 218),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (!_linkSent) ...[
                  Center(
                    child: TextField(
                      controller: emailcontroller,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: 'email',
                        hintText: 'e.g. someone@domain.com',
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _sending ? null : _sendLink,
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Send sign-in link'),
                  ),
                ] else
                  TextButton(
                    onPressed: () => setState(() => _linkSent = false),
                    child: Text(
                      'Use a different email',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final FirebaseAuth auth = FirebaseAuth.instance;

class Logic {
  static String get _hostingDomain => DefaultFirebaseOptions.web.authDomain!;

  static ActionCodeSettings _actionCodeSettings() {
    return ActionCodeSettings(
      url: 'https://$_hostingDomain/finishSignUp',
      handleCodeInApp: true,
      androidPackageName: 'com.niloy.demo',
      androidInstallApp: true,
      androidMinimumVersion: '1',
    );
  }

  static Future<void> sendSignInLink(String email) async {
    await auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: _actionCodeSettings(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailLinkPrefsKey, email);
  }
}
