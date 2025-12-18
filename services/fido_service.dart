import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FidoService {
  static const _credentialKey = 'fido_credential_id';
  static final _storage = FlutterSecureStorage();
  static final _client = Supabase.instance.client;

  static final PasskeyAuthenticator _authenticator = PasskeyAuthenticator(
    relyingParty: RelyingParty(
      id: 'authguard.app', // Your domain / app ID
      name: 'AuthGuard',
    ),
    debugMode: true,
  );

  /// Registers a passkey and stores credential ID both locally and in Supabase
  static Future<void> registerPasskey(String userId, String userEmail) async {
  static Future<void> registerPasskey(String userId) async {
    try {
      final options = PublicKeyCredentialCreationOptions(
        user: PublicKeyCredentialUserEntity(
          id: utf8.encode(userId),
          name: userEmail,
          displayName: userEmail,
          // The name and displayName are often the user's email or username.
          name: userId,
          displayName: userId,
        ),
        challenge: _generateChallenge(),
      );

      final credential = await _authenticator.register(options);

      if (credential != null) {
        final credentialId = base64.encode(credential.rawId);
        final publicKey = base64.encode(credential.response.attestationObject);

        await _storage.write(key: _credentialKey, value: credentialId);

        await _client.from('fido_keys').insert({
          'user_id': userId,
          'credential_id': credentialId,
          'public_key': publicKey,
        });
      }
    } catch (e, st) {
      print('[FIDO Register Error] $e\n$st');
    }
  }

  /// Authenticates user with FIDO2 passkey
  static Future<bool> authenticateWithPasskey(String userId) async {
    try {
      final storedId = await _storage.read(key: _credentialKey);
      if (storedId == null) {
        print('[FIDO] No stored credential ID found.');
        return false;
      }

      final options = PublicKeyCredentialRequestOptions(
        challenge: _generateChallenge(),
        allowCredentials: [
          PublicKeyCredentialDescriptor(id: base64.decode(storedId)),
        ],
      );

      final result = await _authenticator.authenticate(options);
      return result != null;
    } catch (e, st) {
      print('[FIDO Auth Error] $e\n$st');
      return false;
    }
  }

  /// Clears stored credential from local storage
  static Future<void> clearCredential() async {
    await _storage.delete(key: _credentialKey);
  }

  /// Generates a secure random challenge
  static List<int> _generateChallenge({int length = 32}) {
    return List<int>.generate(length, (_) => _randomByte());
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  static int _randomByte() => DateTime.now().millisecondsSinceEpoch % 256;
}
