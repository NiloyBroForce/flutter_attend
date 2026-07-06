import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';//used for debug show
void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     debugPaintSizeEnabled = true;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Container(
                color: Colors.redAccent,
                height: 50,
                width: 50,
                child: const Text('Dart'),
              ),
              Container(
                color: Colors.greenAccent,
                height: 50,
                width: 100,
                child: const Text('is'),
              ),
              Container(
                color: Colors.blueAccent,
                height: 50,
                width: 50,
                child: const Text('Cool'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}