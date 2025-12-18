import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/fido_service.dart';

import 'home_screen.dart';
import 'unlock_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String message = '';
  Timer? sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    _startSessionPolling();
  }

  void _startSessionPolling() {
    sessionCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;

      if (session != null && user != null && mounted) {
        sessionCheckTimer?.cancel();
        await Future.delayed(
            const Duration(milliseconds: 600)); // Let Supabase settle
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UnlockScreen(
              onUnlocked: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    sessionCheckTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    setState(() => loading = true);
    try {
      final authRes = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (authRes.user != null && mounted) {
        await FidoService.registerPasskey(authRes.user!.id);

        sessionCheckTimer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UnlockScreen(
              onUnlocked: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => message = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _signUpWithEmail() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );
      if (mounted) {
        setState(() => message = 'Check your email for confirmation.');
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => message = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      Provider.google,
      redirectTo: 'io.supabase.authguard://login-callback',
    );
    // Polling will catch the session change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text('AuthGuard Login', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : _signInWithEmail,
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: loading ? null : _signUpWithEmail,
                  child: const Text('Register'),
                ),
                const Divider(),
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(message, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
