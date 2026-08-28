import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key, required this.studentEmail});

  final String studentEmail;

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late final TextEditingController code;

  @override
  void initState() {
    super.initState();
    code = TextEditingController();
  }

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }
Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  if(Platform.isAndroid){
    final android=await deviceInfo.androidInfo;
    return android.id;
  }
    return 'unknown device ';
  }
  Future<void> write(String enteredOtp) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('new')
          .where('activeOtp', isEqualTo: enteredOtp)
          .get();

      if (!mounted) return;

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Invalid code")));
        return;
      }
      final docs = querySnapshot.docs.first;

      final data=docs.data();

      final Timestamp otpCreatedAt=data['otpCreatedAt'];

      final age = Timestamp.now().toDate().difference(otpCreatedAt.toDate());

      if(age.inSeconds>=5){
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Code expired")), ); return;
      }

      final attend=await docs.reference.collection('attend').
      where(
        'studentEmail',
        isEqualTo:widget.studentEmail
      )
      .limit(1)
      .get();

      if(attend.docs.isNotEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance already marked")),
        );
        return;
      }
      final deviceId = await getDeviceId();
      await docs.reference.collection("attend").add({
        'studentEmail': widget.studentEmail,
        'attendanceMarkedAt': FieldValue.serverTimestamp(),
        'deviceId':deviceId,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance marked successfully!")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error giving attendance $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 1, 44),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, color: Colors.white), // Student Icon here
            SizedBox(width: 8),
            Text('Welcome Student', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 5, 0, 51),
        leading: IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 6,
            color: Colors.blueAccent,
            surfaceTintColor: const Color.fromARGB(255, 243, 14, 205),
            shadowColor: const Color.fromARGB(255, 186, 212, 255),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: const Text(
                'Enter code to mark attendance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(221, 231, 218, 218),
                ),
                textAlign: TextAlign.center,
              ), // Internal spacing for content
            ),
          ),

          Center(
            child: TextField(
              controller: code,
              style: TextStyle(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                icon: Icon(Icons.code),
                labelText: 'code',
                hintText: 'e.g. 643211',
              ),
            ),
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () async {
              write(code.text.trim());
            },
            child: Text('Confirm to give attendance'),
          ),
        ],
      ),
    );
  }
}
