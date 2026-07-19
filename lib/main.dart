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

final TextEditingController _emailController=TextEditingController();
final TextEditingController _passwordController=TextEditingController();

  Future<void> _createUser({required String email,required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("★★★ Sign Up Success! UID: ${userCredential.user?.uid}");
    } on FirebaseAuthException catch (e) {
      print("Sign Up Error: ${e.message}");
    }
  }

Future<void>_signUp() async{
  try{
    UserCredential userCredential=await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

  Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
  }
   catch (e) {
      String errorMessage = 'Sign Up failed. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
Future<void>_signIn() async{
  try{
    UserCredential userCredential=await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,

    );

    String username=userCredential.user?.email?.split('@')[0]??'';

    if(userCredential.user?.email?.endsWith('@teacher.com')??false){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TeacherHomeScreen()),
      );
    }
  else if(userCredential.user?.email?.endsWith('@student.com')??false){
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentHomeScreen(username)
        ),
      );
  }
  }

  catch(e){
      print('Error signing in: $e');
      String errorMessage = 'Invalid email or password. Please try again.';

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(
    errorMessage,
    style: TextStyle(color:Colors.white),
  ),
  backgroundColor: Colors.red,
  ),
);
  }
  
}

@override
Widget build(BuildContext context){
  return Scaffold(appBar: AppBar(
    title:Text(''),
  ),
  body: Padding(padding: const EdgeInsets.all(16.0),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
  children:[
    Icon(
      Icons.school,
      size:100,
      color:Colors.blue,
    ),
    SizedBox(height:20),
    Text(
      'Android Attendance',
      style:TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height:20),
TextField(
  controller:_emailController,
  decoration: InputDecoration(
    labelText: 'Email'
  ),
),
    SizedBox(height:20),
TextField(
  controller:_passwordController,
  obscureText: true,
  decoration: InputDecoration(
    labelText: 'Password'
  ),
),
    SizedBox(height:15),
    ElevatedButton(
      onPressed: _signIn,
      style:ElevatedButton.styleFrom(
        backgroundColor:Colors.blue,
        foregroundColor:Colors.white,
      ),
      child: Text('Sign in'),
    ),
      SizedBox(height: 5),
            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Sign Up'),
            ),
  ]
  ),
  ),
  );
}
}