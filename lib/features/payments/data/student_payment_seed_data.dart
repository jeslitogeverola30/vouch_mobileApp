import '../domain/student_payment_item.dart';

class StudentPaymentSeedData {
  StudentPaymentSeedData._();

  static const StudentPaymentSummary summary = StudentPaymentSummary(
    studentId: '2023-0222',
    academicYear: 'A.Y. 2025-2026',
    totalPayable: 99999.00,
  );

  static const List<String> tabs = [
    StudentPaymentTab.all,
    StudentPaymentTab.pending,
    StudentPaymentTab.toPay,
    StudentPaymentTab.paid,
    StudentPaymentTab.rejected,
  ];

  static final List<StudentPaymentItem> paymentItems = [
    const StudentPaymentItem(
      name: 'Donation',
      amount: 'Any Amount',
      dueDate: 'February 28, 2026',
      proof: 'Screenshot_20260228.jpg',
      status: StudentPaymentStatus.pending,
      obligation: 'NON-OBLIGATORY',
      actionText: 'Awaiting Admin Verification...',
    ),
    const StudentPaymentItem(
      name: 'Membership Fee',
      amount: '₱200.00',
      dueDate: 'February 28, 2026',
      proof: 'N/A',
      status: StudentPaymentStatus.toPay,
      obligation: 'OBLIGATORY',
      actionText: 'Submit Proof of Payment',
    ),
    const StudentPaymentItem(
      name: 'CB Polo Shirt Batch 1',
      amount: '₱500.00',
      dueDate: 'March 15, 2026',
      proof: 'N/A',
      status: StudentPaymentStatus.toPay,
      obligation: 'OBLIGATORY',
      actionText: 'Submit Proof of Payment',
    ),
  ];
}
