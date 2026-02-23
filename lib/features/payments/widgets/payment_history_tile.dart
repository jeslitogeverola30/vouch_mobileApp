import 'package:flutter/material.dart';

class PaymentHistoryTile extends StatelessWidget {
  const PaymentHistoryTile({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
