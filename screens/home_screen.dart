import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../services/secure_storage_service.dart';
import '../services/totp_service.dart';
import '../widgets/otp_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  int remaining = TOTPService.getRemainingSeconds();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        remaining = TOTPService.getRemainingSeconds();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<SecureStorageService>(context);
    final userEmail =
        supabase.Supabase.instance.client.auth.currentUser?.email ?? "User";

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('AuthGuard - $userEmail',
              style: const TextStyle(fontSize: 16)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await supabase.Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (_) => false);
                }
              },
            ),
          ],
        ),
        body: storage.accounts.isEmpty
            ? const Center(child: Text('No OTPs available'))
            : ListView.builder(
                itemCount: storage.accounts.length,
                itemBuilder: (context, index) {
                  final account = storage.accounts[index];

                  return OtpCard(
                    account: account,
                    remaining: remaining,
                    onCopy: () {
                      final otp = TOTPService.generateCode(account.secret);
                      Clipboard.setData(ClipboardData(text: otp));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OTP copied')),
                      );
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Account?'),
                          content: Text('${account.issuer} - ${account.label}'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                storage.deleteAccount(account);
                                Navigator.pop(context);
                              },
                              child: const Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.qr_code_scanner),
                      title: const Text("Scan QR Code"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/scan');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text("Enter Manually"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/manual');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
