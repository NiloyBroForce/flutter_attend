import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'teacher.dart';

class SubjectAttendanceScreen extends StatelessWidget {
  final String subjectId;

  const SubjectAttendanceScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${subjectId.toUpperCase()} Attendance'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(TeacherHomeScreen.attendanceCollection)
            .doc(subjectId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text('Subject not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final rawStudents = data['students'];

          // "students" is stored as an ARRAY of maps on the subject document
          // (not a subcollection) — e.g. arrayUnion({...}) from the student side.
          final students = <Map<String, dynamic>>[
            if (rawStudents is List)
              ...rawStudents.whereType<Map>().map(
                    (m) => m.map((k, v) => MapEntry(k.toString(), v)),
                  ),
          ];

          // Newest first. ISO 8601 timestamps sort correctly as plain strings.
          students.sort((a, b) {
            final aTime = (a['timestamp'] ?? '').toString();
            final bTime = (b['timestamp'] ?? '').toString();
            return bTime.compareTo(aTime);
          });

          if (students.isEmpty) {
            return const Center(child: Text('No students have attended yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = students[index];

              final username = (entry['username'] ?? '—').toString();
              final userid = (entry['userid'] ?? '—').toString();
              final deviceid = (entry['deviceid'] ?? '—').toString();
              final timestampRaw = entry['timestamp']?.toString();
              final formattedTime = _formatTimestamp(timestampRaw);

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              username,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(label: 'User ID', value: userid),
                      _InfoRow(label: 'Device ID', value: deviceid),
                      _InfoRow(label: 'Time', value: formattedTime),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(String? isoString) {
    if (isoString == null) return '—';
    final parsed = DateTime.tryParse(isoString);
    if (parsed == null) return isoString;
    final local = parsed.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}