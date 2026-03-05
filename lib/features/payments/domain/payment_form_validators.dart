class PaymentFormValidators {
  PaymentFormValidators._();

  static String? feeTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a fee title';
    }

    return null;
  }

  static String? feeAmount(String? value) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) {
      return 'Please enter amount';
    }

    final parsed = double.tryParse(cleaned.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) {
      return 'Enter valid amount';
    }

    return null;
  }

  static String? feeDueDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select date';
    }

    return null;
  }

  static String? receiverAccountName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter account name';
    }

    if (text.length < 3) {
      return 'Account name is too short';
    }

    return null;
  }

  static String? receiverPosition(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter position';
    }

    return null;
  }

  static String? receiverGcashNumber(String? value) {
    final digits = value?.trim() ?? '';
    if (digits.isEmpty) {
      return 'Please enter GCash number';
    }

    final isValid = RegExp(r'^09\d{9}$').hasMatch(digits);
    if (!isValid) {
      return 'Use valid PH mobile format';
    }

    return null;
  }
}
