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
        title: Text('${subjectId.toUpperCase()} Sessions'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(TeacherHomeScreen.attendanceCollection)
            .doc(subjectId)
            .collection('sessions')
            .orderBy('sessionStartedAt', descending: true)
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
            return const Center(child: Text('No sessions recorded yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final startedTs = data['sessionStartedAt'] as Timestamp?;
              final endedTs = data['sessionEndedAt'] as Timestamp?;
              final rawStudents = data['students'];
              final studentCount = (rawStudents is List)
                  ? rawStudents.length
                  : 0;

              final startedLabel = startedTs != null
                  ? _formatDateTime(startedTs.toDate())
                  : 'Unknown start time';
              final statusLabel = endedTs == null ? 'In progress' : 'Ended';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: endedTs == null
                        ? Colors.green
                        : Colors.blueGrey,
                    child: Icon(
                      endedTs == null ? Icons.podcasts : Icons.event_available,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    startedLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$statusLabel • $studentCount student(s)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionAttendanceScreen(
                          subjectId: subjectId,
                          sessionId: doc.id,
                          sessionLabel: startedLabel,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}

class SessionAttendanceScreen extends StatelessWidget {
  final String subjectId;
  final String sessionId;
  final String sessionLabel;

  const SessionAttendanceScreen({
    super.key,
    required this.subjectId,
    required this.sessionId,
    required this.sessionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${subjectId.toUpperCase()} — $sessionLabel'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(TeacherHomeScreen.attendanceCollection)
            .doc(subjectId)
            .collection('sessions')
            .doc(sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text('Session not found.'));
          }

          final data = snapshot.data!.data() ?? {};
          final rawStudents = data['students'];

          final students = <Map<String, dynamic>>[
            if (rawStudents is List)
              ...rawStudents.whereType<Map>().map(
                (m) => m.map((k, v) => MapEntry(k.toString(), v)),
              ),
          ];

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
              final regid = (entry['regId'] ?? '—').toString();
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
                      _InfoRow(label: 'User ID', value: regid),
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
