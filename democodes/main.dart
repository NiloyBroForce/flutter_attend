import 'package:flutter/material.dart';

void main() {
  runApp(const myImageApp());
}

class myImageApp extends StatelessWidget {
  const myImageApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('Img'),
          ),
          backgroundColor: Colors.brown[700],
        ),
        body: const SafeArea(
          child: Image(
            image: AssetImage('images/mobile-gallery.png'),
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
