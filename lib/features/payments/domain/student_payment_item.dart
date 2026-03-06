class StudentPaymentStatus {
  StudentPaymentStatus._();

  static const String pending = 'Pending';
  static const String toPay = 'To Pay';
  static const String paid = 'Paid';
  static const String rejected = 'Rejected';
}

class StudentPaymentTab {
  StudentPaymentTab._();

  static const String all = 'All';
  static const String pending = 'Pending';
  static const String toPay = 'To Pay';
  static const String paid = 'Paid';
  static const String rejected = 'Rejected';
}

class StudentPaymentSummary {
  final String studentId;
  final String academicYear;
  final double totalPayable;

  const StudentPaymentSummary({
    required this.studentId,
    required this.academicYear,
    required this.totalPayable,
  });
}

class StudentPaymentItem {
  final int? requirementId;
  final String name;
  final String amount;
  final String dueDate;
  final String proof;
  final String status;
  final String obligation;
  final String actionText;
  final String rejectionNote;

  const StudentPaymentItem({
    this.requirementId,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.proof,
    required this.status,
    required this.obligation,
    required this.actionText,
    this.rejectionNote = '',
  });
}
