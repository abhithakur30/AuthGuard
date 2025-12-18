import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../utils/uri_parser.dart';
import '../services/secure_storage_service.dart';
import '../models/account_model.dart';
import 'home_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;
  bool _hasScanned = false;

  Future<void> _processScan(String rawValue) async {
    debugPrint("🔍 Scanned QR: $rawValue");

    final parsed = OTPAuthUri.parse(rawValue);
    if (parsed == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP QR code')),
        );
      }
      return;
    }

    final storage = Provider.of<SecureStorageService>(context, listen: false);
    final existing = storage.accounts;

    if (!existing.any((a) => a.secret == parsed.secret)) {
      await storage.addAccount(AccountModel(
        issuer: parsed.issuer,
        label: parsed.label,
        secret: parsed.secret,
      ));
    }

    // Allow UI to settle before navigating
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted && !_hasScanned) {
      _hasScanned = true;

      debugPrint("✅ Navigating to HomeScreen");

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(),
            onDetect: (BarcodeCapture capture) async {
              if (_isProcessing || _hasScanned) return;

              _isProcessing = true;

              final barcode = capture.barcodes.first;
              final rawValue = barcode.rawValue;

              if (rawValue != null && rawValue.startsWith('otpauth://')) {
                await _processScan(rawValue);
              }

              _isProcessing = false;
            },
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
