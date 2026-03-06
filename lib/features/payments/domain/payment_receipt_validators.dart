class PaymentReceiptValidators {
  PaymentReceiptValidators._();

  static const int maxFileSizeMegabytes = 10;
  static const int maxFileSizeBytes = maxFileSizeMegabytes * 1024 * 1024;

  static bool isFileSizeAllowed(int fileSizeInBytes) {
    return fileSizeInBytes <= maxFileSizeBytes;
  }
}
