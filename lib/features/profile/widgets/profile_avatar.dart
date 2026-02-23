import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      child: imageUrl == null ? const Icon(Icons.person) : null,
    );
  }
}
