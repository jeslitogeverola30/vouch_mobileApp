import 'package:flutter/material.dart';

class ReceiptUploader extends StatelessWidget {
  const ReceiptUploader({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload Receipt'),
    );
  }
}
