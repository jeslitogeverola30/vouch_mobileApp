import '../domain/qr_payload_entity.dart';
import '../domain/qr_scanner_repository.dart';
import 'qr_data_parser.dart';

class QrScannerRepositoryImpl implements QrScannerRepository {
  QrScannerRepositoryImpl({QrDataParser? parser})
    : _parser = parser ?? const QrDataParser();

  final QrDataParser _parser;

  @override
  QrPayloadEntity? parsePayload(String rawValue) {
    return _parser.parse(rawValue);
  }

  @override
  Future<bool> verifyQrCode(String rawValue) async {
    final payload = parsePayload(rawValue);
    return payload?.isValid ?? false;
  }
}
