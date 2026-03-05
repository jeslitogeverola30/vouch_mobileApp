class PaymentSubmissionStatus {
  PaymentSubmissionStatus._();

  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
}

class PaymentSubmission {
  final String id;
  final String studentName;
  final String studentProgram;
  final String courseName;
  final String amount;
  final String paymentMethod;
  final String timeAgo;
  final String avatarText;
  final String proofFile;
  final String receiptAssetPath;
  final String status;

  const PaymentSubmission({
    required this.id,
    required this.studentName,
    required this.studentProgram,
    required this.courseName,
    required this.amount,
    required this.paymentMethod,
    required this.timeAgo,
    required this.avatarText,
    required this.proofFile,
    required this.receiptAssetPath,
    required this.status,
  });
}
