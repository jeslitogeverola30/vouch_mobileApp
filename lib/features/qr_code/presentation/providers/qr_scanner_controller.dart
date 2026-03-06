import 'package:flutter/foundation.dart';

import '../../data/qr_scanner_repository_impl.dart';
import '../../domain/qr_payload_entity.dart';
import '../../domain/qr_scanner_repository.dart';

class QrScannerController extends ChangeNotifier {
  QrScannerController({QrScannerRepository? repository})
    : _repository = repository ?? QrScannerRepositoryImpl();

  final QrScannerRepository _repository;

  QrPayloadEntity? _lastPayload;
  bool _isVerified = false;

  QrPayloadEntity? get lastPayload => _lastPayload;
  bool get isVerified => _isVerified;

  Future<bool> verify(String rawValue) async {
    final payload = _repository.parsePayload(rawValue);
    final verified = await _repository.verifyQrCode(rawValue);

    _lastPayload = payload;
    _isVerified = verified;
    notifyListeners();

    return verified;
  }

  void clear() {
    _lastPayload = null;
    _isVerified = false;
    notifyListeners();
  }
}
