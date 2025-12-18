import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/fido_service.dart';

class UnlockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const UnlockScreen({super.key, required this.onUnlocked});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _authStatus = "App Locked";
  bool _firstTimeLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAuthLogic();
    });
  }

  Future<void> _handleAuthLogic() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLoggedInBefore = prefs.getBool('hasLoggedInBefore') ?? false;

    if (!hasLoggedInBefore) {
      await prefs.setBool('hasLoggedInBefore', true);
      setState(() {
        _firstTimeLogin = true;
        _authStatus =
            "🎉 User registered!\nPlease restart the app to continue.";
      });
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final fidoSuccess = await FidoService.authenticateWithPasskey(user.id);
      if (fidoSuccess && mounted) {
        widget.onUnlocked();
        return;
      }
    }

    // Fallback to biometric unlock
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _authStatus = "Authenticating...";
    });

    try {
      final canCheck =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canCheck) {
        setState(() {
          _authStatus = "Biometric authentication not supported.";
        });
        return;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Scan fingerprint to unlock',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate && mounted) {
        widget.onUnlocked();
      } else {
        setState(() => _authStatus = "Authentication failed.");
      }
    } catch (e) {
      setState(() => _authStatus = "Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Unlock AuthGuard"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _firstTimeLogin ? Icons.celebration : Icons.lock_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                _authStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(
                    _firstTimeLogin ? Icons.restart_alt : Icons.fingerprint),
                label: Text(_firstTimeLogin ? "Restart App" : "Authenticate"),
                onPressed: _firstTimeLogin
                    ? () => _exitApp(context)
                    : (_isAuthenticating ? null : _authenticate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Restart Required"),
        content: const Text("Please close and reopen the app."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
