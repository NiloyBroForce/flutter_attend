import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherScreen extends StatelessWidget {
  const TeacherScreen({super.key});

  Future<void> addSubjectWithCustomId(String subName) async {
    await FirebaseFirestore.instance.collection('new').doc(subName).set({
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _subjectDialog(BuildContext context) {
    String subName = '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Center(child: Text('Add New Subject')),
        content: TextField(
          onChanged: (value) => subName = value,
          decoration: InputDecoration(hintText: 'e.g. SWE250'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subName.trim().isEmpty) return;

              await addSubjectWithCustomId(subName);

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 0, 104),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.co_present_sharp, color: Colors.white),
            SizedBox(width: 8),
            Text('Welcome Teacher', style: TextStyle(color: Colors.white)),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('new').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No subjects found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final subId = docs[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text('Subject $subId'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => list(subId: subId),
                      ),
                    );
                  },
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Code(subId: subId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Generate code'),
                  ),
                ),
              );
            },
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _subjectDialog(context),
        tooltip: 'Add Subject',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class Code extends StatefulWidget {
  final String subId;

  const Code({super.key, required this.subId});

  @override
  State<Code> createState() => _CodeState();
}

class _CodeState extends State<Code> {
  late Timer _timer;

  String _otp = '';
  int _secondsLeft = 6;
  @override

  void initState() {
    super.initState();
    _generateAndWriteCode();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if(_secondsLeft>1){
        setState(() {_secondsLeft--;});
      }
      else{
      _generateAndWriteCode();
      }
    });
  }

  String generateCode() {
    final random = Random();

    final otp = 100000 + random.nextInt(900000);

    return otp.toString();
  }

  Future<void> _generateAndWriteCode() async {
    final otp = generateCode();

    if (mounted) {
      setState(() => _otp = otp);
      _secondsLeft=6;
    }

    try {
      await FirebaseFirestore.instance.collection('new').doc(widget.subId).set({
        'activeOtp': otp,
        'otpCreatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error giving attendance: $e")));
    }
  }
Future<void> _endAttendance() async {

    try {
      await FirebaseFirestore.instance.collection('new').doc(widget.subId).set({
        'activeOtp': FieldValue.delete(),
        'otpCreatedAt': FieldValue.delete(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error ending attendance: $e")));
    }
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Generator'),
      ),
      body: Center(
        child:Column(
        children:[
          
          Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '6-Digit OTP: $_otp',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
           const SizedBox(height: 20),

            Text(
              'Expires in $_secondsLeft seconds',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 40),

        ElevatedButton(
              onPressed: _endAttendance,
              style: ElevatedButton.styleFrom(fixedSize: const Size(250, 60)),
              child: const Text(
                'End Attendance',
                style: TextStyle(fontSize: 18),
              ),
            ),
        ],
        ),
      ),
    );
  }
}

class list extends StatefulWidget {
  final String subId;

  const list({super.key, required this.subId});

  @override
  State<list> createState() => _listState();
}

class _listState extends State<list> {
  late final Future<List<Map<String, dynamic>>> _studentFuture;

  @override
  void initState() {
    super.initState();
    _studentFuture = student(widget.subId);
  }

  Future<List<Map<String, dynamic>>> student(String subId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('new')
        .doc(subId)
        .collection('session')
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        'studentEmail': doc.data()['studentEmail'] ?? '',
        'attendanceMarkedAt': doc.data()['attendanceMarkedAt'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subject Details: ${widget.subId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('has error');
          }
          final data = snapshot.data;
          if (data == null) return const Text('No data');

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final record = data[index];
              final email = record['studentEmail'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(email),
                  subtitle: const Text('Attendance Marked'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
