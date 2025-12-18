import 'package:otp/otp.dart';

class TOTPService {
  static String generateCode(String base32Secret) {
    try {
      final cleanedSecret = base32Secret.replaceAll(' ', '').toUpperCase();

      return OTP.generateTOTPCodeString(
        cleanedSecret,
        DateTime.now().millisecondsSinceEpoch,
        interval: 30,
        length: 6,
        algorithm: Algorithm.SHA1,
        isGoogle: true, // ✅ key to match Google Authenticator
      );
    } catch (e) {
      print('TOTP generation failed: $e');
      return 'ERROR';
    }
  }

  static int getRemainingSeconds() {
    return 30 - (DateTime.now().second % 30);
  }
}
