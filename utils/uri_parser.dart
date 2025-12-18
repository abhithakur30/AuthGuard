class OTPAuthUri {
  final String issuer;
  final String label;
  final String secret;

  OTPAuthUri({required this.issuer, required this.label, required this.secret});

  static OTPAuthUri? parse(String uri) {
    try {
      final parsedUri = Uri.parse(uri);

      if (parsedUri.scheme != 'otpauth') return null;

      final type = parsedUri.host;
      if (type != 'totp') return null;

      final path = parsedUri.path.substring(1);
      final labelParts = path.split(':');
      String label = labelParts.length == 2 ? labelParts[1] : path;
      String issuer = parsedUri.queryParameters['issuer'] ?? labelParts[0];
      String secret = parsedUri.queryParameters['secret'] ?? '';

      if (secret.isEmpty) return null;

      return OTPAuthUri(
        issuer: Uri.decodeComponent(issuer),
        label: Uri.decodeComponent(label),
        secret: secret,
      );
    } catch (_) {
      return null;
    }
  }
}
