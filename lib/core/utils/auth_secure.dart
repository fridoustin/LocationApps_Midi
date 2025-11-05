// lib/core/utils/auth_secure.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _secureStorage = const FlutterSecureStorage();
final _supabase = Supabase.instance.client;

class SecureAuth {
  static const _kEmail = 'remember_email';
  static const _kPassword = 'remember_password';

  /// Save credentials securely. Use only if user opts-in ("Remember me").
  static Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _kEmail, value: email);
    await _secureStorage.write(key: _kPassword, value: password);
  }

  /// Clear stored credentials (call on logout).
  static Future<void> clearSavedCredentials() async {
    await _secureStorage.delete(key: _kEmail);
    await _secureStorage.delete(key: _kPassword);
  }

  /// Return stored credentials or null if none.
  static Future<Map<String, String>?> readCredentials() async {
    final email = await _secureStorage.read(key: _kEmail);
    final password = await _secureStorage.read(key: _kPassword);
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Try sign in using stored credentials. Returns true if sign-in succeeded.
  static Future<bool> tryAutoLoginFromSavedCredentials() async {
    final creds = await readCredentials();
    if (creds == null) return false;
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: creds['email']!,
        password: creds['password']!,
      );
      final session = res.session ?? _supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }
}
