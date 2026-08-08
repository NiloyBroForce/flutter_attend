import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'attendance.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;
    final String email = currentUser?.email ?? '';
    final String userId = email.contains('@') ? email.split('@')[0] : email;
    final String username =
        currentUser?.displayName ?? (currentUser?.email ?? 'Student User');

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F17),
        elevation: 0,
        title: const Text(
          'Attendance Portal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(
                        0xFF38BDF8,
                      ).withOpacity(0.15),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF38BDF8),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ID: $userId',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Scan Class QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Embedded Camera View
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF334155),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: QRScannerWidget(username: username, userid: userId),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  final String username;
  final String userid;

  const QRScannerWidget({
    super.key,
    required this.username,
    required this.userid,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget>
    with TickerProviderStateMixin {
  final MobileScannerController scannerController = MobileScannerController();
  late AnimationController animationController;

  bool _isProcessing = false;
  String? _statusMessage;
  Color _statusColor = Colors.white70;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: scannerController,
          onDetect: _handleDetection,
        ),
        _buildCustomQRAnimation(),

        // Dynamic Status Banner
        if (_statusMessage != null)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _statusColor.withOpacity(0.5)),
              ),
              child: Text(
                _statusMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Processing Overlay
        if (_isProcessing)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final codeValue = barcodes.first.rawValue;
    if (codeValue == null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Verifying Attendance Token...';
      _statusColor = Colors.white70;
    });

    try {
      final payload = jsonDecode(codeValue) as Map<String, dynamic>;
      final subjectId = payload['subjectId'] as String?;
      final token = payload['token'] as String?;

      if (subjectId == null || token == null) {
        _showTransientMessage('Invalid QR code format.', Colors.redAccent);
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection('attendance')
          .doc(subjectId);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        _showTransientMessage('Subject not found.', Colors.redAccent);
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentToken = data['currentToken'] as String?;
      final expiresAtTs = data['tokenExpiresAt'] as Timestamp?;

      if (currentToken == null || token != currentToken) {
        _showTransientMessage(
          'This QR code is no longer active.',
          Colors.redAccent,
        );
        return;
      }

      if (expiresAtTs == null ||
          expiresAtTs.toDate().isBefore(DateTime.now())) {
        _showTransientMessage('This QR code has expired.', Colors.redAccent);
        return;
      }

      final existingStudents = (data['students'] as List?) ?? [];
      final alreadyMarked = existingStudents.any(
        (entry) => entry is Map && entry['userid'] == widget.userid,
      );

      if (alreadyMarked) {
        _showTransientMessage(
          'Already marked present for $subjectId.',
          Colors.orangeAccent,
        );
        return;
      }

      await scannerController.stop();
      await _updateAttendance(subjectId, docRef);

      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AttendanceConfirmationScreen(subjectId, widget.username),
          ),
        );
      }
    } catch (e) {
      _showTransientMessage('Error scanning QR code.', Colors.redAccent);
    }
  }

  void _showTransientMessage(String message, Color color) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
      _statusColor = color;
      _isProcessing = false;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _statusMessage = null);
    });
  }

  Widget _buildCustomQRAnimation() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.maxWidth * 0.65;
        return Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Positioned(
                    top: (boxSize - 4) * animationController.value,
                    child: Container(
                      width: boxSize,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38BDF8),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF38BDF8),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateAttendance(
    String subjectId,
    DocumentReference<Map<String, dynamic>> docRef,
  ) async {
    try {
      final studentRecord = {
        'username': widget.username,
        'userid': widget.userid,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await docRef.set({
        'students': FieldValue.arrayUnion([studentRecord]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating attendance: $e');
    }
  }

  @override
  void dispose() {
    scannerController.stop();
    scannerController.dispose();
    animationController.dispose();
    super.dispose();
  }
}
