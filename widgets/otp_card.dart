import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/totp_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OtpCard extends StatelessWidget {
  final AccountModel account;
  final int remaining;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const OtpCard({
    super.key,
    required this.account,
    required this.remaining,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext ctx) {
    final otp = TOTPService.generateCode(account.secret);

    return Animate(
      effects: [FadeEffect(duration: 300.ms), MoveEffect(duration: 300.ms)],
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onLongPress: onDelete,
          title: Text(account.issuer,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(account.label),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(otp, style: const TextStyle(fontSize: 24, letterSpacing: 2)),
              Text('$remaining s')
            ],
          ),
          onTap: onCopy,
        ),
      ),
    );
  }
}
