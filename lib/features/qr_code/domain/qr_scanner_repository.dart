import 'qr_payload_entity.dart';

abstract class QrScannerRepository {
  QrPayloadEntity? parsePayload(String rawValue);

  Future<bool> verifyQrCode(String rawValue);
}
