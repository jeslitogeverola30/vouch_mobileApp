class PaymentDateFormatters {
  PaymentDateFormatters._();

  static String monthDayYearNumeric(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$month/$day/${date.year}';
  }
}
