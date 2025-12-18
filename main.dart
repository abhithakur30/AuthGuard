import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/secure_storage_service.dart';
import 'services/remote_config_service.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/unlock_screen.dart';
import 'screens/manual_entry_screen.dart';
import 'screens/disabled_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(); // 👈 Load .env

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SecureStorageService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuthGuard',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const RemoteCheckWrapper(),
      routes: {
        '/': (_) => const HomeScreen(),
        '/scan': (_) => const QRScannerScreen(),
        '/manual': (_) => const ManualEntryScreen(),
      },
    );
  }
}

class RemoteCheckWrapper extends StatefulWidget {
  const RemoteCheckWrapper({super.key});

  @override
  State<RemoteCheckWrapper> createState() => _RemoteCheckWrapperState();
}

class _RemoteCheckWrapperState extends State<RemoteCheckWrapper> {
  bool _loading = true;
  bool _enabled = true;
  String _message = "";

  @override
  void initState() {
    super.initState();
    _checkAll();
  }

  Future<void> _checkAll() async {
    final config = await RemoteConfigService.fetchRemoteConfig();
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _enabled = config['app_enabled'] ?? true;
      _message =
          config['message'] ?? "App is disabled. Please contact developer";
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_enabled) {
      return DisabledScreen(message: _message);
    }

    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      return const LoginScreen();
    }

    return UnlockScreen(
      onUnlocked: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      },
    );
  }
}
