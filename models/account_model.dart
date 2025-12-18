class AccountModel {
  final String issuer;
  final String label;
  final String secret;

  AccountModel({
    required this.issuer,
    required this.label,
    required this.secret,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final issuer = json['issuer'] ?? 'Unknown Issuer';
    final label = json['label'] ?? 'Unknown Account';
    final secret = json['secret'];

    if (secret == null || secret.isEmpty) {
      throw ArgumentError('TOTP secret cannot be null or empty');
    }

    return AccountModel(
      issuer: issuer,
      label: label,
      secret: secret,
    );
  }

  Map<String, dynamic> toJson() => {
        'issuer': issuer,
        'label': label,
        'secret': secret,
      };
}
