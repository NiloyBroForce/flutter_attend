import 'dart:io';
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
  String _deviceId = 'Fetching...';

  @override
  void initState() {
    super.initState();
    _fetchDeviceId();
  }

  // Get platform-specific unique hardware identity
  Future<void> _fetchDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String id = 'DEV-UNKNOWN';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.id; // e.g., "TP1A.220624.014"
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? 'IOS-UNKNOWN';
      }
    } catch (e) {
      id = 'DEV-983X-8822'; // fallback fallback
    }

    if (mounted) {
      setState(() {
        _deviceId = id;
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
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
      // 1. Deep Dark Background
      backgroundColor: const Color(0xFF0F172A), // Slate Dark / Near Black
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isScanning = false;
                });
              },
            ),
            const Expanded(
              child: Text(
                'Student Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
        backgroundColor: const Color(0xFF1E293B), // Dark Navy Surface
        elevation: 0,
      ),
      body: _isScanning
          ? Center(
              child: QRScannerWidget(
                username: username,
                userid: userId,
                deviceid: _deviceId,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon with Glow effect
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            size: 64,
                            color: Color(0xFF38BDF8), // Bright Sky Blue
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Student Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Crisp White Title
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Cards with High Contrast Text
                      _buildProfileCard(
                        icon: Icons.person_rounded,
                        label: 'Student Name',
                        value: username,
                      ),
                      const SizedBox(height: 14),

                      _buildProfileCard(
                        icon: Icons.badge_rounded,
                        label: 'Reg ID / User ID',
                        value: userId,
                      ),
                      const SizedBox(height: 14),

                      _buildProfileCard(
                        icon: Icons.phonelink_lock_rounded,
                        label: 'Device Hardware ID',
                        value: _deviceId,
                      ),
                      const SizedBox(height: 36),

                      // Electric Blue Action Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(
                            0xFF2563EB,
                          ), // Vibrant Blue
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.blueAccent.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 22,
                        ),
                        label: const Text(
                          'Scan QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isScanning = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Refactored Profile Card Widget
  Widget _buildProfileCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark surface container
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF334155), // Subtle border outline
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container with Cyan/Blue Tint
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF38BDF8), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8), // Soft Light Slate Label
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white, // Pure High-Contrast White Text
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  final String username;
  final String userid;
  final String deviceid;

  const QRScannerWidget({
    super.key,
    required this.username,
    required this.userid,
    required this.deviceid,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget>
    with TickerProviderStateMixin {
  final MobileScannerController scannerController = MobileScannerController();
  bool attended = false;
  String? subjectName;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildQRView(context),
        _buildCustomQRAnimation(),
        const Positioned(
          top: 150,
          child: Text(
            'Scan QR code',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRView(BuildContext context) {
    return MobileScanner(
      controller: scannerController,
      onDetect: (BarcodeCapture capture) async {
        if (attended) return;

        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isNotEmpty) {
          final String? codeValue = barcodes.first.rawValue;

          if (codeValue != null) {
            setState(() {
              attended = true;
              subjectName = codeValue;
            });

            await scannerController.stop();

            await _updateAttendance(subjectName);

            if (mounted) {
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceConfirmationScreen(
                    subjectName ?? '',
                    widget.username,
                  ),
                ),
              );
            }
          }
        }
      },
    );
  }

  Widget _buildCustomQRAnimation() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return _buildRedLine(animationController.value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRedLine(double animationValue) {
    return Positioned(
      top: 0,
      child: Container(
        width: 300,
        height: 2,
        color: Colors.red,
        margin: EdgeInsets.only(top: 296 * animationValue),
      ),
    );
  }

  Future<void> _updateAttendance(String? subjectName) async {
    try {
      if (subjectName != null) {
        CollectionReference attendanceCollection =
            FirebaseFirestore.instance.collection('attendance');

        Map<String, dynamic> studentRecord = {
          'username': widget.username,
          'userid': widget.userid,
          'deviceid': widget.deviceid,
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Write student payload to array inside subject doc
        await attendanceCollection.doc(subjectName).set({
          'students': FieldValue.arrayUnion([studentRecord]),
        }, SetOptions(merge: true));

        debugPrint('Attendance record updated with hardware tokens.');
      }
    } catch (e) {
      debugPrint('Error updating attendance: $e');
    }
  }

  @override
  void dispose() {
    scannerController.dispose();
    animationController.dispose();
    super.dispose();
  }
}