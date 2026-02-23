import 'package:flutter/material.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(label: Text('Events')),
        Chip(label: Text('Payments')),
        Chip(label: Text('Profile')),
      ],
    );
  }
}
