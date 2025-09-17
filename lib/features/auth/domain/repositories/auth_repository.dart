import '../entities/user.dart';

abstract class AuthRepository {
  // Stream untuk memantau perubahan status otentikasi
  Stream<User?> get onAuthStateChange;

  // Mendapatkan user yang sedang login
  User? get currentUser;

  // Fungsi untuk Sign In
  Future<void> signInWithEmailPassword(String email, String password);

  // Fungsi untuk Sign Up
  Future<void> signUpWithEmailPassword(String email, String password);

  // Fungsi untuk Sign Out
  Future<void> signOut();

  Future<bool> isUserAuthorized(String userId);

  // Fungsi untuk mengirim email reset password
  Future<void> sendPasswordResetEmail(String email);

  // Fungsi untuk memperbarui password user
  Future<void> updateUserPassword(String newPassword);
}