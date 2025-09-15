
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/datasource/auth_remote_datasource.dart';
import '../../domain/entities/user.dart' as app;
import '../../domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  // Mengubah Supabase User menjadi User Entity kita
  app.User? _convertSupabaseUser(supabase.User? user) {
    if (user == null) return null;
    return app.User(id: user.id, email: user.email ?? '');
  }

  @override
  app.User? get currentUser => _convertSupabaseUser(_dataSource.currentUser);

  @override
  Stream<app.User?> get onAuthStateChange {
    return _dataSource.onAuthStateChange.map((authState) {
      return _convertSupabaseUser(authState.session?.user);
    });
  }

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      await _dataSource.signInWithEmailPassword(email, password);
      final user = _dataSource.currentUser;
      if (user == null) throw Exception('User tidak ditemukan setelah login.');

      final bool isAllowed = await isUserAuthorized(user.id);

      if (!isAllowed) {
        await _dataSource.signOut();
        throw Exception('Hanya Location Specialist yang dapat login.');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signUpWithEmailPassword(String email, String password) {
    return _dataSource.signUpWithEmailPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<bool> isUserAuthorized(String userId) async {
    print("--- [DEBUG] MASUK isUserAuthorized ---");

    final connectivity = await Connectivity().checkConnectivity();
    print("--- [DEBUG] Hasil Cek Koneksi: $connectivity ---");

    // --- PERBAIKAN UTAMA DI SINI ---
    // Kita cek apakah list hasil koneksi mengandung '.none'
    if (connectivity.contains(ConnectivityResult.none)) {
      print("--- [DEBUG] OFFLINE, Seharusnya langsung return true.");
      return true;
    }

    print("--- [DEBUG] ONLINE, Mencoba melakukan panggilan jaringan ke Supabase...");
    try {
      const allowedPositionId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
      final response = await _dataSource.client
          .from('users')
          .select('position_id')
          .eq('id', userId)
          .single();
      
      final userPositionId = response['position_id'];
      print("--- [DEBUG] Panggilan jaringan berhasil, userPositionId: $userPositionId");
      return userPositionId == allowedPositionId;
    } catch (e) {
      print("--- [DEBUG] Terjadi ERROR di dalam blok try-catch saat online.");
      print('Gagal melakukan pengecekan otorisasi: $e');
      return false;
    }
  }
}