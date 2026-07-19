import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AttendanceList extends StatelessWidget {

  final String subjectName;

  const AttendanceList({required this.subjectName});

  @override
  Widget build(BuildContext context) {

    DateTime currentDate=DateTime.now();


    return StreamBuilder(stream: FirebaseFirestore.instance
          .collection('attendance')
          .doc(subjectName.toLowerCase().trim())
          .snapshots(),
           builder: (context,AsyncSnapshot<DocumentSnapshot>snapshot ){
            if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
              if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

       if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              'No attendance record found for "${subjectName.toLowerCase()}"',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final List<dynamic> students =
            data?['students'] as List<dynamic>? ?? [];

            if (students.isEmpty) {
          return const Center(
            child: Text(
              'Nobody has checked in yet.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: EdgeInsets.all(4),
            child:Text(
                'Attended Students for $subjectName',
              style:TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),

            ),
            ),
              Padding(padding: EdgeInsets.all(4),
            child:Text(
                'Date: ${_formatDate(currentDate)}',
              style:TextStyle(
                fontSize: 14,
                  color: Colors.black54,
              ),

            ),
            ),
            const Divider(),
            Expanded(
              child:ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom:4),
                    child: ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal:0,vertical:-4),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal:8,
                      ),
                      title: Text(
                        '${index + 1}. ${students?[index] ?? ''}',
                       style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
           },
           );
  }

  String _formatDate(DateTime date){
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';

  }
   String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}