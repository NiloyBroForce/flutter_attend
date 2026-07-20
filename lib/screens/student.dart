import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'attendance.dart';

class StudentHomeScreen extends StatefulWidget {
  // No fields needed in the constructor anymore!
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form key to validate text fields before unlocking the scanner
  final _formKey = GlobalKey<FormState>();

  // These will be managed entirely by the student on the dashboard layout
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  // Hardcoded or dynamically fetched inside the dashboard, immutable to the user
  final String _deviceId = "DEV-983X-8822";

  bool _isScanning = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
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
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isScanning = false;
                });
              },
            ),
            Expanded(
              child: Text(
                _nameController.text.isEmpty
                    ? 'Student Dashboard'
                    : 'Home - ${_nameController.text}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
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
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _isScanning
          ? Center(
              child: QRScannerWidget(
                // Sent to scanner only after strict dashboard validation passes
                username: _nameController.text.trim(),
                userid: _idController.text.trim(),
                deviceid: _deviceId,
              ),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey, // Form validation wraps the inputs
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 80,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Setup Your Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You must enter your Name and Reg No before you can scan.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Required Student Name Input
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Your Name *',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required to proceed';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(
                              () {},
                            ); // Updates the App Bar text in real-time
                          },
                        ),
                        const SizedBox(height: 16),

                        // Required User ID Input
                        TextFormField(
                          controller: _idController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Your Reg No *',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'User ID is required to proceed';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Fixed Device ID View (Read Only)
                        TextFormField(
                          initialValue: _deviceId,
                          readOnly: true,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Your Device ID (Auto-Captured)',
                            prefixIcon: const Icon(Icons.phonelink_lock),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Scan QR Trigger Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          label: const Text(
                            'Scan QR Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            // Enforce rule: validation must pass before transitioning to scanner state
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isScanning = true;
                              });
                            } else {
                              // Optional feedback if validation fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please complete your profile details first!',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  final String username;
  final String userid;
  final String deviceid;


  const QRScannerWidget({super.key, required this.username,
    required this.userid,
  required this.deviceid});

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
        CollectionReference attendanceCollection = FirebaseFirestore.instance
            .collection('attendance');

        Map<String, dynamic> studentRecord = {
          'username': widget.username,
          'userid': widget.userid,
          'deviceid': widget.deviceid,
          'timestamp': DateTime.now()
              .toIso8601String(), // Optional: highly helpful for tracking logs
        };

        // 2. Safely push this object inside the 'students' list array using merge options
        await attendanceCollection.doc(subjectName).set({
          'students': FieldValue.arrayUnion([studentRecord]),
        }, SetOptions(merge: true));

        print(
          'Attendance record updated with username, ID, and hardware tokens.',
        );
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
