import '../domain/payment_submission.dart';

class PaymentReceiverReference {
  final String name;
  final String role;
  final String number;

  const PaymentReceiverReference({
    required this.name,
    required this.role,
    required this.number,
  });
}

class AdminPaymentSeedData {
  AdminPaymentSeedData._();

  static const PaymentReceiverReference receiverReference =
      PaymentReceiverReference(
        name: 'Juan Dela Cruz',
        role: 'Treasurer - ACES',
        number: '0912 345 6789',
      );

  static final List<PaymentSubmission> submissions = [
    const PaymentSubmission(
      id: '1',
      studentName: 'Maria Santos',
      studentProgram: 'BSCS - 3rd Year',
      courseName: 'Panaghigalaay 2025 T-Shirt',
      amount: '350.00',
      paymentMethod: 'GCash',
      timeAgo: '2m ago',
      avatarText: 'MS',
      proofFile: 'receipt-sample1.jpg',
      receiptAssetPath: 'assets/images/receipt-sample1.jpg',
      status: PaymentSubmissionStatus.pending,
    ),
    const PaymentSubmission(
      id: '2',
      studentName: 'Juan Dela Cruz',
      studentProgram: 'BSED - 2nd Year',
      courseName: 'General Assembly Fee',
      amount: '150.00',
      paymentMethod: 'Maya',
      timeAgo: '15m ago',
      avatarText: 'JD',
      proofFile: 'receipt-sample2.jpg',
      receiptAssetPath: 'assets/images/receipt-sample2.jpg',
      status: PaymentSubmissionStatus.approved,
    ),
    const PaymentSubmission(
      id: '3',
      studentName: 'Anna Reyes',
      studentProgram: 'BSIT - 1st Year',
      courseName: 'Membership Fee',
      amount: '200.00',
      paymentMethod: 'GCash',
      timeAgo: '1h ago',
      avatarText: 'AR',
      proofFile: 'receipt-sample1.jpg',
      receiptAssetPath: 'assets/images/receipt-sample1.jpg',
      status: PaymentSubmissionStatus.rejected,
    ),
    const PaymentSubmission(
      id: '4',
      studentName: 'Paolo Ramirez',
      studentProgram: 'BSIT - 4th Year',
      courseName: 'Foundation Week Donation',
      amount: '500.00',
      paymentMethod: 'Bank Transfer',
      timeAgo: '3h ago',
      avatarText: 'PR',
      proofFile: 'receipt-sample2.jpg',
      receiptAssetPath: 'assets/images/receipt-sample2.jpg',
      status: PaymentSubmissionStatus.pending,
    ),
  ];
}
