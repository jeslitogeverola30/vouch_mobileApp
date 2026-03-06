import 'student_payment_item.dart';

class StudentPaymentFilters {
  StudentPaymentFilters._();

  static List<StudentPaymentItem> filterByTab({
    required List<StudentPaymentItem> items,
    required String tab,
  }) {
    if (tab == StudentPaymentTab.pending) {
      return items
          .where((item) => item.status == StudentPaymentStatus.pending)
          .toList();
    }

    if (tab == StudentPaymentTab.toPay) {
      return items
          .where((item) => item.status == StudentPaymentStatus.toPay)
          .toList();
    }

    if (tab == StudentPaymentTab.paid) {
      return items
          .where((item) => item.status == StudentPaymentStatus.paid)
          .toList();
    }

    if (tab == StudentPaymentTab.rejected) {
      return items
          .where((item) => item.status == StudentPaymentStatus.rejected)
          .toList();
    }

    return items;
  }

  static bool canSubmitProof(StudentPaymentItem item) {
    return item.status == StudentPaymentStatus.toPay ||
        item.status == StudentPaymentStatus.rejected;
  }
}
