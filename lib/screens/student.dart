import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'attendance.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isScanning = false;
  String _deviceId = 'Fetching';

  @override
  void initState() {
    super.initState();
    _fetchDeviceId();
  }

  Future<void> _fetchDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String id = 'DEV-UNKNOWN';

    try {
      final androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;
    } catch (_) {
      id = 'DEV-983X-8822';
    }

    if (mounted) {
      setState(() => _deviceId = id);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  Widget _buildUserHero(String name, String regId) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Name : ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 139, 163, 197),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(
                      255,
                      238,
                      225,
                      225,
                    ).withValues(alpha: 0.02),
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reg ID : ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 151, 176, 212),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      regId,
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 120,
                    vertical: 6,
                  ),

                  child: const Row(mainAxisSize: MainAxisSize.min),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCTA() {
    return Container(
      padding: const EdgeInsets.all(26),
      child: Column(
        children: [
          Stack(alignment: Alignment.center),
          const SizedBox(height: 20),
          const Text(
            'Mark Attendance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan the QR code displayed by your teacher to verify presence',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromARGB(255, 166, 189, 221),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              onPressed: () => setState(() => _isScanning = true),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'Launch Scanner',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(String deviceId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Text(
            'Hardware ID:',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              deviceId,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;
    final String email = currentUser?.email ?? '';

    final String studentName =
        currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty
        ? currentUser.displayName!
        : (email.split('@')[0]);

    final String regId = email.split('@')[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Row(
          children: [
            const SizedBox(width: 12),
            const Text(
              'Student Portal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937).withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFF9CA3AF),
                size: 18,
              ),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
          ),
        ],
      ),
      body: _isScanning
          ? QRScannerWidget(
              studentName: studentName,
              regId: regId,
              deviceId: _deviceId,
              onCancel: () => setState(() => _isScanning = false),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildUserHero(studentName, regId),
                      const SizedBox(height: 20),
                      _buildScanCTA(),
                      const SizedBox(height: 20),
                      _buildDeviceInfoCard(_deviceId),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  final String studentName;
  final String regId;
  final String deviceId;
  final VoidCallback onCancel;

  const QRScannerWidget({
    super.key,
    required this.studentName,
    required this.regId,
    required this.deviceId,
    required this.onCancel,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  late MobileScannerController controller;
  bool _isProcessing = false;
  String? _statusMessage;
  Color _statusColor = Colors.white70;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(controller: controller, onDetect: _handleDetection),
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.55),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(painter: ScannerOverlayPainter()),
          ),
        ),
        Positioned(
          top: 20,
          left: 16,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: widget.onCancel,
              ),
            ),
          ),
        ),
        Positioned(
          top: 90,
          left: 20,
          right: 20,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.center_focus_weak_rounded,
                    color: Color(0xFF38BDF8),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Align QR code within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_statusMessage != null)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statusColor.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing &&
                      _statusMessage == 'Verifying QR Code') ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Verifying QR Code...';
      _statusColor = Colors.white;
    });

    try {
      final payload = jsonDecode(rawValue) as Map<String, dynamic>;
      final subjectId = payload['subjectId'] as String?;
      final sessionId = payload['sessionId'] as String?;
      final token = payload['token'] as String?;

      if (subjectId == null || sessionId == null || token == null) {
        _showTransientMessage('Invalid QR format.', Colors.redAccent);
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection('attendance')
          .doc(subjectId)
          .collection('sessions')
          .doc(sessionId);

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        _showTransientMessage('Session record not found.', Colors.redAccent);
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentToken = data['currentToken'] as String?;
      final expiresAtTs = data['tokenExpiresAt'] as Timestamp?;
      final endedAtTs = data['sessionEndedAt'] as Timestamp?;

      if (currentToken == null || token != currentToken) {
        _showTransientMessage('QR code expired/invalid.', Colors.redAccent);
        return;
      }

      if (expiresAtTs == null ||
          expiresAtTs.toDate().isBefore(DateTime.now())) {
        _showTransientMessage('QR code has expired.', Colors.redAccent);
        return;
      }

      if (endedAtTs != null) {
        _showTransientMessage(
          'This class session has ended.',
          Colors.redAccent,
        );
        return;
      }

      final existingStudents = (data['students'] as List?) ?? [];
      final alreadyMarked = existingStudents.any(
        (entry) => entry is Map && (entry['regId'] == widget.regId),
      );

      if (alreadyMarked) {
        _showTransientMessage('Already marked present.', Colors.orangeAccent);
        return;
      }

      await controller.stop();
      await _updateAttendance(docRef);

      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AttendanceConfirmationScreen(subjectId, widget.studentName),
          ),
        );
      }
    } catch (e) {
      _showTransientMessage('Invalid QR payload.', Colors.redAccent);
    }
  }

  void _showTransientMessage(String message, Color color) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
      _statusColor = color;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusMessage = null;
          _isProcessing = false;
        });
      }
    });
  }

  Future<void> _updateAttendance(
    DocumentReference<Map<String, dynamic>> docRef,
  ) async {
    final studentRecord = {
      'username': widget.studentName,
      'regId': widget.regId,
      'deviceid': widget.deviceId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await docRef.set({
      'students': FieldValue.arrayUnion([studentRecord]),
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const double cornerLength = 28.0;

    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, 0)
        ..lineTo(cornerLength, 0),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerLength),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLength)
        ..lineTo(0, size.height)
        ..lineTo(cornerLength, size.height),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
