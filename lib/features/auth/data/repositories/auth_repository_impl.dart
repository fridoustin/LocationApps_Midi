
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
      // 1. Lakukan login seperti biasa menggunakan DataSource
      await _dataSource.signInWithEmailPassword(email, password);

      // 2. Jika login berhasil, Supabase punya sesi user. Ambil ID-nya.
      final supabase.User? user = _dataSource.currentUser;
      if (user == null) {
        // Seharusnya tidak terjadi, tapi untuk jaga-jaga
        throw Exception('Gagal mendapatkan informasi pengguna setelah login.');
      }

      print('--- PROSES PENGECEKAN POSISI ---');
      print('User ID yang login: ${user.id}');

      // ID posisi yang diizinkan untuk login
      const allowedPositionId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
      print('ID Posisi yang diizinkan: $allowedPositionId');

      // 3. Query ke tabel 'profiles' (atau nama tabel user Anda) untuk mendapatkan position_id
      // Asumsikan nama tabel Anda adalah 'profiles'
      final profileResponse = await _dataSource.client // butuh akses ke SupabaseClient
          .from('users') // Ganti 'profiles' jika nama tabel Anda berbeda
          .select('position_id')
          .eq('id', user.id)
          .single();
      
      final userPositionId = profileResponse['position_id'];
      print('ID Posisi user dari database: $userPositionId');

      final bool isAllowed = userPositionId == allowedPositionId;
      print('Apakah posisi diizinkan? $isAllowed');

      // 4. Bandingkan position_id pengguna dengan ID yang diizinkan
      if (!isAllowed) {
        print('Posisi tidak cocok! Memaksa logout...');
        await _dataSource.signOut();
        throw Exception('Hanya Location Specialist yang dapat login.');
      }

      print('Posisi cocok! Login berhasil.');
    } catch (e) {
      // Teruskan error (baik dari Supabase atau dari pengecekan kita)
      print('Terjadi error saat pengecekan posisi: $e');
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
}