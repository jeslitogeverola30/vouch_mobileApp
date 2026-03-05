import 'payment_submission.dart';

class PaymentSubmissionFilters {
  PaymentSubmissionFilters._();

  static const String allFeeTypesLabel = 'All Fee Types';

  static List<String> feeTypeOptions(List<PaymentSubmission> submissions) {
    final feeTypes =
        submissions.map((submission) => submission.courseName).toSet().toList()
          ..sort();

    return [allFeeTypesLabel, ...feeTypes];
  }

  static List<PaymentSubmission> filterSubmissions({
    required List<PaymentSubmission> submissions,
    required String status,
    required String selectedFeeType,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    return submissions.where((submission) {
      final matchesStatus = submission.status == status;
      final matchesFeeType =
          selectedFeeType == allFeeTypesLabel ||
          submission.courseName == selectedFeeType;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          submission.studentName.toLowerCase().contains(normalizedQuery) ||
          submission.studentProgram.toLowerCase().contains(normalizedQuery) ||
          submission.courseName.toLowerCase().contains(normalizedQuery);

      return matchesStatus && matchesFeeType && matchesQuery;
    }).toList();
  }
}
