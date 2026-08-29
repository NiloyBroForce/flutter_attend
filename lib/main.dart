import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'student.dart';
import 'firebase_options.dart';
import 'teacher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'android',
      theme: ThemeData(brightness: Brightness.dark),
      home: UI(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UI extends StatelessWidget {
  const UI({super.key});

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
          final teacher = domain.contains('sust') && !student;

          if (student) return StudentScreen(studentEmail: userEmail,studentReg:registration);
          if (teacher) return TeacherScreen();
        }
        return const Login();
      },
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  late final emailcontroller = TextEditingController();
  late final passwordcontroller = TextEditingController();

  Future<void> _submit_Sign_in() async {
    final email = emailcontroller.text.trim();
    final password = passwordcontroller.text;

    return Logic.Sign_in(email, password);
  }

  Future<void> _submit_Sign_up() async {
    final email = emailcontroller.text.trim();
    final password = passwordcontroller.text;

    return Logic.Sign_up(email, password);
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
                const SizedBox(height: 40),

                Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 6,
                  color: const Color.fromRGBO(68, 138, 255, 1),
                  surfaceTintColor: const Color.fromARGB(255, 243, 14, 205),
                  shadowColor: const Color.fromARGB(255, 186, 212, 255),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text(
                      'Enter your email and password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(221, 231, 218, 218),
                      ),
                      textAlign: TextAlign.center,
                    ), 
                  ),
                ),
                Center(
                  child: TextField(
                    controller: emailcontroller,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'email',
                      hintText: 'e.g. someone@domain.com',
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: TextField(
                    obscureText: true,
                    controller: passwordcontroller,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'password',
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _submit_Sign_in,
                      child: Text('Sign in'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _submit_Sign_up,
                      child: Text("Sign up"),
                    ),
                  ],
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
  static Future<void> Sign_in(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> Sign_up(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }
}
