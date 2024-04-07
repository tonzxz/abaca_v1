import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MyGrades extends StatefulWidget {
  const MyGrades({super.key});

  @override
  State<MyGrades> createState() => _MyGradesState();
}

class _MyGradesState extends State<MyGrades> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('Grades');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grades'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _databaseReference.onValue,
        builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            Map<dynamic, dynamic> data =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Widget> gradeWidgets = [];

            data.forEach((key, value) {
              gradeWidgets.add(
                Card(
                  child: ListTile(
                    title: Text(key),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Classified: $value'),
                      ],
                    ),
                  ),
                ),
              );
            });

            return ListView(
              children: gradeWidgets,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
