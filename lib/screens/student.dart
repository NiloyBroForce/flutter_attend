import 'package:flutter/material.dart';
import 'package:flutter_attend/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'attendance.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class StudentHomeScreen extends StatelessWidget {
  final String username;

  const StudentHomeScreen(this.username);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            Text(
              'Student Home - $username',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(child: QRScannerWidget(username: username)),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  final String username;

  const QRScannerWidget({super.key, required this.username});

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
        String userName = widget.username;
        CollectionReference attendanceCollection = FirebaseFirestore.instance
            .collection('attendance');

        await attendanceCollection.doc(subjectName).set({
          'students': FieldValue.arrayUnion([userName]),
        }, SetOptions(merge: true));

        print('Attendance updated in Firestore.');
      } else {
        print('Subject name is null.');
      }
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  @override
  void dispose() {
    scannerController.dispose();
    animationController.dispose();
    super.dispose();
  }
}
