import 'package:flutter/material.dart';

class StudentRow extends StatelessWidget {
  const StudentRow({super.key, required this.name, this.onTap});

  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
