import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerCard extends StatelessWidget {
  const QrScannerCard({
    super.key,
    required this.scannerController,
    required this.onCodeDetected,
    required this.onRetryTap,
    required this.isProcessing,
    required this.scanModeLabel,
  });

  final MobileScannerController scannerController;
  final ValueChanged<String> onCodeDetected;
  final VoidCallback onRetryTap;
  final bool isProcessing;
  final String scanModeLabel;

  static const Color _royalBlue = Color(0xFF003DA5);
  static const Color _gold = Color(0xFFFFC107);

  Widget _buildCornerGuide({
    required Alignment alignment,
    required Border border,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _royalBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Ionicons.scan_outline,
                  color: _royalBlue,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Scanner Ready',
                  style: TextStyle(
                    color: _royalBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 235,
            decoration: BoxDecoration(
              color: _royalBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _royalBlue.withOpacity(0.12)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: MobileScanner(
                      controller: scannerController,
                      fit: BoxFit.cover,
                      placeholderBuilder: (context, child) {
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Initializing camera...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: onRetryTap,
                                  icon: const Icon(
                                    Ionicons.refresh,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Retry',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, child) {
                        String message =
                            'Unable to open camera. Please try again.';

                        switch (error.errorCode) {
                          case MobileScannerErrorCode.permissionDenied:
                            message =
                                'Camera permission is denied. Allow camera access in app settings, then retry.';
                            break;
                          case MobileScannerErrorCode.unsupported:
                            message =
                                'Camera scanning is unsupported on this device/emulator.';
                            break;
                          default:
                            final details =
                                error.errorDetails?.message?.trim() ?? '';
                            if (details.isNotEmpty) {
                              message = details;
                            }
                        }

                        return Container(
                          color: Colors.black,
                          padding: const EdgeInsets.all(14),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Ionicons.camera_outline,
                                  color: Colors.white,
                                  size: 34,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: onRetryTap,
                                  icon: const Icon(Ionicons.refresh, size: 16),
                                  label: const Text('Retry Camera'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.55),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      onDetect: (capture) {
                        if (isProcessing) {
                          return;
                        }

                        for (final barcode in capture.barcodes) {
                          final rawValue = barcode.rawValue?.trim() ?? '';
                          if (rawValue.isNotEmpty) {
                            onCodeDetected(rawValue);
                            break;
                          }
                        }
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.12)),
                  ),
                  Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _gold.withOpacity(0.95),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        _buildCornerGuide(
                          alignment: Alignment.topLeft,
                          border: const Border(
                            top: BorderSide(color: _royalBlue, width: 3),
                            left: BorderSide(color: _royalBlue, width: 3),
                          ),
                        ),
                        _buildCornerGuide(
                          alignment: Alignment.topRight,
                          border: const Border(
                            top: BorderSide(color: _royalBlue, width: 3),
                            right: BorderSide(color: _royalBlue, width: 3),
                          ),
                        ),
                        _buildCornerGuide(
                          alignment: Alignment.bottomLeft,
                          border: const Border(
                            bottom: BorderSide(color: _royalBlue, width: 3),
                            left: BorderSide(color: _royalBlue, width: 3),
                          ),
                        ),
                        _buildCornerGuide(
                          alignment: Alignment.bottomRight,
                          border: const Border(
                            bottom: BorderSide(color: _royalBlue, width: 3),
                            right: BorderSide(color: _royalBlue, width: 3),
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Ionicons.scan_circle_outline,
                            color: Colors.white,
                            size: 62,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        scanModeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (isProcessing)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.45),
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Positioned(
                    bottom: 10,
                    child: Text(
                      'Align code inside the square frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: scannerController,
            builder: (context, state, _) {
              final zoom = state.zoomScale;
              final isZoomed = zoom > 0.5;

              Widget buildZoomButton({
                required String label,
                required bool selected,
                required VoidCallback onTap,
              }) {
                return Expanded(
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          selected ? Colors.white : _royalBlue,
                      backgroundColor:
                          selected ? _royalBlue : Colors.transparent,
                      side: BorderSide(
                        color: selected
                            ? _royalBlue
                            : _royalBlue.withOpacity(0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: selected ? Colors.white : _royalBlue,
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    buildZoomButton(
                      label: '1x',
                      selected: !isZoomed,
                      onTap: () {
                        scannerController.setZoomScale(0.0);
                      },
                    ),
                    const SizedBox(width: 8),
                    buildZoomButton(
                      label: '2x',
                      selected: isZoomed,
                      onTap: () {
                        scannerController.setZoomScale(1.0);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Text(
            'Tip: Hold the device steady and keep good lighting for faster detection.',
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
