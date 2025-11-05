// lib/core/utils/biometric_auth.dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _localAuth = LocalAuthentication();
final _secureStorage = const FlutterSecureStorage();

class BiometricAuth {
  static const _kEmail = 'remember_email';
  static const _kPassword = 'remember_password';
  static const _kBiometricEnabled = 'biometric_enabled';

  /// Check if device supports biometrics and has enrolled biometrics
  static Future<bool> canAuthenticateBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isDeviceSupported) return false;

      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Prompt biometric and return true if success
  static Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool stickyAuth = false,
  }) async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: stickyAuth,
          useErrorDialogs: true,
        ),
      );
      return didAuthenticate;
    } catch (_) {
      return false;
    }
  }

  /// Save flag and credentials (use after successful login if user enabled biometrics)
  static Future<void> enableBiometric(String email, String password) async {
    await _secureStorage.write(key: _kEmail, value: email);
    await _secureStorage.write(key: _kPassword, value: password);
    await _secureStorage.write(key: _kBiometricEnabled, value: 'true');
  }

  static Future<void> disableBiometric() async {
    await _secureStorage.delete(key: _kEmail);
    await _secureStorage.delete(key: _kPassword);
    await _secureStorage.delete(key: _kBiometricEnabled);
  }

  static Future<bool> isBiometricEnabled() async {
    final v = await _secureStorage.read(key: _kBiometricEnabled);
    return v == 'true';
  }

  /// Attempt biometric login: authenticate -> read stored creds -> return creds map or null
  static Future<Map<String, String>?> tryBiometricLogin() async {
    final enabled = await isBiometricEnabled();
    if (!enabled) return null;
    final canBio = await canAuthenticateBiometrics();
    if (!canBio) return null;

    final ok = await authenticate(reason: 'Authenticate to login');
    if (!ok) return null;

    final email = await _secureStorage.read(key: _kEmail);
    final password = await _secureStorage.read(key: _kPassword);
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }
}
