import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'attendance_list.dart';
import 'package:flutter_attend/main.dart';
import 'package:qr_flutter/qr_flutter.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class TeacherHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget _buildBody(BuildContext context) {
    User? user = _auth.currentUser;

    String? teacherEmail = user?.email;
    String? subjectName = _extractSubjectName(teacherEmail);
    String subject = subjectName!;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 100.0, color: Colors.blue),
          SizedBox(height: 20.0),
          Text(
            'Welcome, Teacher!',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SubjectQRCodeScreen(subjectName: subject),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Generate QR code'),
          ),
          SizedBox(height: 20.0),
          Expanded(child: _buildAttendanceList(context,subjectName)),
        ],
      ),
    );
  }
}

Widget _buildAttendanceList(BuildContext context, String? subjectName) {
  if (subjectName == null) {
    return Center(child: Text('Subject name not found.'));
  }
  return Container(
    height: 450,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[200], // Matches the visual display panel base
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: AttendanceList(subjectName: subjectName),
  );
}

String? _extractSubjectName(String? email) {
  if (email == null) return null;

  List<String> parts = email.split('@');
  if (parts.length == 2) {
    return parts[0];
  } else {
    return null;
  }
}

class SubjectQRCodeScreen extends StatelessWidget {
  final String subjectName;

  const SubjectQRCodeScreen({super.key,this.subjectName="cse"});

  @override
  Widget build(BuildContext context) {
    final String qrData = subjectName.toLowerCase().trim();

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code for $subjectName'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scan to Mark Attendance',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Subject: $qrData',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData, 
                version: QrVersions.auto,
                size:
                    250.0,
                gapless: false,
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
            ),

            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
