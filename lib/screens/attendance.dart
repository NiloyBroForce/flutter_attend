import 'package:flutter/material.dart';
import 'student.dart';

class AttendanceConfirmationScreen extends StatelessWidget {
  final String subjectName;
  final String username;

  AttendanceConfirmationScreen(this.subjectName, String userEmail)
      : username = userEmail.split('@')[0];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance confirm'),
        leading: IconButton(
          onPressed: () {
            print('Back button pressed');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomeScreen(username),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body:Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100.0,
            ),
            SizedBox(height: 16.0),
            Text(
              'You have successfully attended for',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text(
              'subjectName',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ]
      ))
    );
  }
}
