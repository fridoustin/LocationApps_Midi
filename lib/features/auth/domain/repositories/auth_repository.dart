import '../entities/user.dart';

abstract class AuthRepository {
  // Stream to monitor authentication state changes
  Stream<User?> get onAuthStateChange;

  // Get the currently logged-in user
  User? get currentUser;

  // Function to Sign In
  Future<void> signInWithEmailPassword(String email, String password);

  // Function to Sign Up
  Future<void> signUpWithEmailPassword(String email, String password);

  // Function to Sign Out
  Future<void> signOut();

  Future<bool> isUserAuthorized(String userId);

  // Function to send a password reset email
  Future<void> sendPasswordResetEmail(String email);

  // NEW: Function to verify the password reset OTP
  Future<void> verifyOtp(String email, String token);

  // Function to update the user's password
  Future<void> updateUserPassword(String newPassword);
}
