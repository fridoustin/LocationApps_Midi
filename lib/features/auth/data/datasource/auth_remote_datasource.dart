import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client;

  SupabaseClient get client => _client;
  AuthRemoteDataSource(this._client);

  /// User who is currently logged in
  User? get currentUser => _client.auth.currentUser;

  /// Stream to monitor authentication state changes
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Sign in with email & password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Sign up with email & password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Signup failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Logout user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    }
  }

  /// Send a password reset OTP. The `redirectTo` is removed.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Failed to send reset email: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Verify the OTP for password recovery.
  Future<void> verifyOtp(String email, String token) async {
    try {
      await _client.auth.verifyOTP(
        token: token,
        type: OtpType.recovery,
        email: email,
      );
    } on AuthException catch (e) {
      throw Exception('Invalid code: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update the user's password.
  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception('Failed to update password: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
