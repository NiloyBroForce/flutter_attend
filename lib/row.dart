import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Container(
                color: Colors.redAccent,
                height: 50,
                width: 50,
                child: const Text(
                  'Dart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const Spacer(flex: 2),
              Container(
                color: Colors.greenAccent,
                height: 75,
                width: 50,
                import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SafeArea(
            child: Container(
              color: Colors.amberAccent,
              height: 300,
              width: 200,
              margin: const EdgeInsets.all(20),
              child: const Align(
                alignment: Alignment(1.0, 0.5),
                child: Text('is'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
              ),
               const Spacer(),//add spacer to add space
                             Expanded(
                flex: 1,

              Container(
                color: Colors.blueAccent,
                height: 100,
                width: 50,
                child: const Text(
                  'cool',
                  style: TextStyle(fontSize: 25),
                ),
              ),
                             ),
            ],
          ),
        ),
      ),
    );
  }
}