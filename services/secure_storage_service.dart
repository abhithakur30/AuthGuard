import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/account_model.dart';

class SecureStorageService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _key = 'accounts';

  List<AccountModel> _accounts = [];
  List<AccountModel> get accounts => _accounts;

  SecureStorageService() {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final data = await _storage.read(key: _key);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _accounts = jsonList.map((e) => AccountModel.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> addAccount(AccountModel account) async {
    _accounts.add(account);
    await _save();
  }

  Future<void> deleteAccount(AccountModel account) async {
    _accounts.remove(account);
    await _save();
  }

  Future<void> _save() async {
    final jsonList = _accounts.map((e) => e.toJson()).toList();
    await _storage.write(key: _key, value: jsonEncode(jsonList));
    notifyListeners();
  }
}
