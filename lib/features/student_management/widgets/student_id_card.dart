import 'package:flutter/material.dart';

class StudentIdCard extends StatelessWidget {
  const StudentIdCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name),
      ),
    );
  }
}
