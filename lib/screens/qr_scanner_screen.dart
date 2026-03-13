import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();
  bool _handledResult = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _returnValue(String value) {
    if (_handledResult || value.trim().isEmpty) {
      return;
    }

    _handledResult = true;
    Navigator.of(context).pop(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    String? rawValue;
                    for (final barcode in capture.barcodes) {
                      final candidate = barcode.rawValue;
                      if (candidate != null && candidate.trim().isNotEmpty) {
                        rawValue = candidate;
                        break;
                      }
                    }

                    if (rawValue != null) {
                      _returnValue(rawValue);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _manualController,
              decoration: const InputDecoration(
                labelText: 'Manual QR value',
                hintText: 'Enter token if camera scan is unavailable',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _returnValue(_manualController.text),
                child: const Text('Use This Value'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
