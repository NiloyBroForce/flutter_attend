import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'attendance_list.dart';
import 'package:flutter_attend/main.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  static const String attendanceCollection = 'attendance';
  static const String studentsSubcollection = 'students';

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<void> _showAddSubjectDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final subjectId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Subject'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                labelText: 'Subject name',
                hintText: 'e.g. cse101',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Subject name cannot be empty';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(
                    dialogContext,
                    controller.text.trim().toLowerCase(),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (subjectId == null || subjectId.isEmpty) return;
    if (!context.mounted) return;

    final docRef = FirebaseFirestore.instance
        .collection(attendanceCollection)
        .doc(subjectId);

    final existing = await docRef.get();
    if (existing.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject "$subjectId" already exists.')),
        );
      }
      return;
    }

    await docRef.set({'createdAt': Timestamp.now()});

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Subject "$subjectId" added.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(attendanceCollection)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('No subjects yet. Tap "Add Subject" to create one.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final subjectId = docs[index].id;
              return _SubjectCard(subjectId: subjectId);
            },
          );
        },
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subjectId;

  const _SubjectCard({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF1E3A8A);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubjectAttendanceScreen(subjectId: subjectId),
            ),
          );
        },
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubjectQRCodeScreen(subjectName: subjectId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                subjectId.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              _AttendanceCountBadge(subjectId: subjectId),
              const SizedBox(height: 6),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SubjectQRCodeScreen(subjectName: subjectId),
                    ),
                  );
                },
                child: const Text(
                  'Generate QR code',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceCountBadge extends StatelessWidget {
  final String subjectId;

  const _AttendanceCountBadge({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(TeacherHomeScreen.attendanceCollection)
          .doc(subjectId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final rawStudents = data?['students'];
        final count = rawStudents is List ? rawStudents.length : 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: count > 0
                ? Colors.greenAccent.withOpacity(0.9)
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count attended',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: count > 0 ? Colors.black87 : Colors.white70,
            ),
          ),
        );
      },
    );
  }
}

/// Displays a QR code for [subjectName] that rotates every 15 seconds.
///
/// The current token is written to the subject's Firestore document
/// (`currentToken` / `tokenExpiresAt`) so that a student's scan can be
/// validated server-side — a screenshotted or expired code will not work.
class SubjectQRCodeScreen extends StatefulWidget {
  final String subjectName;

  const SubjectQRCodeScreen({super.key, this.subjectName = "cse"});

  @override
  State<SubjectQRCodeScreen> createState() => _SubjectQRCodeScreenState();
}

class _SubjectQRCodeScreenState extends State<SubjectQRCodeScreen> {
  static const _rotationDuration = Duration(seconds:15);

  late final String subjectId;
  late final DocumentReference<Map<String, dynamic>> _docRef;

  String _currentToken = '';
  DateTime _expiresAt = DateTime.now();
  int _secondsLeft = 30;
  Timer? _rotationTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    subjectId = widget.subjectName.toLowerCase().trim();
    _docRef = FirebaseFirestore.instance
        .collection(TeacherHomeScreen.attendanceCollection)
        .doc(subjectId);
    _startSession();
  }

  Future<void> _startSession() async {
    // Opening the QR screen starts a fresh attendance session: new token,
    // cleared list of who's marked present.
    await _rotateToken(resetStudents: true);
    _rotationTimer = Timer.periodic(_rotationDuration, (_) => _rotateToken());
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = _expiresAt.difference(DateTime.now()).inSeconds;
      setState(() => _secondsLeft = remaining.clamp(0, 30));
    });
  }

  Future<void> _rotateToken({bool resetStudents = false}) async {
    final token = _generateToken();
    final expiresAt = DateTime.now().add(_rotationDuration);

    final data = <String, dynamic>{
      'currentToken': token,
      'tokenExpiresAt': Timestamp.fromDate(expiresAt),
    };
    if (resetStudents) {
      data['students'] = <String>[];
      data['sessionStartedAt'] = Timestamp.now();
    }

    await _docRef.set(data, SetOptions(merge: true));

    if (mounted) {
      setState(() {
        _currentToken = token;
        _expiresAt = expiresAt;
        _secondsLeft = 30;
      });
    }
  }

  String _generateToken() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(24, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _countdownTimer?.cancel();
    // Invalidate the token so a screenshot of the last code shown can't be
    // scanned after the teacher leaves this screen.
    _docRef.set({'tokenExpiresAt': Timestamp.now()}, SetOptions(merge: true));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _currentToken.isEmpty
        ? null
        : jsonEncode({'subjectId': subjectId, 'token': _currentToken});

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code for ${widget.subjectName}'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan to Mark Attendance',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Subject: $subjectId',
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
              child: qrData == null
                  ? const SizedBox(
                      width: 250,
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 250.0,
                      gapless: false,
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(40, 40),
                      ),
                    ),
            ),

            const SizedBox(height: 20),
            Text(
              'Refreshes in $_secondsLeft s',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _LiveAttendanceCount(subjectId: subjectId),

            const SizedBox(height: 30),
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

class _LiveAttendanceCount extends StatelessWidget {
  final String subjectId;

  const _LiveAttendanceCount({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(TeacherHomeScreen.attendanceCollection)
          .doc(subjectId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final rawStudents = data?['students'];
        final count = rawStudents is List ? rawStudents.length : 0;
        return Text(
          '$count student${count == 1 ? '' : 's'} marked present this session',
          style: const TextStyle(fontSize: 13, color: Colors.greenAccent),
        );
      },
    );
  }
}