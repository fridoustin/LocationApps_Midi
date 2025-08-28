// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// 1. Provider untuk SupabaseClient
final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

// 2. Provider untuk AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSource(client);
});

// 3. Provider untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// 4. Provider UTAMA: Stream untuk status autentikasi
// Provider ini akan memberitahu aplikasi kita secara real-time
// apakah ada user yang sedang login atau tidak.
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final supabaseClient = ref.watch(supabaseClientProvider);
  return authRepository.onAuthStateChange.asyncMap((appUser) async {
    // Jika user logout (null), langsung teruskan.
    if (appUser == null) {
      return null;
    }

    // Jika user login, JANGAN langsung percaya. Cek dulu posisinya.
    try {
      const allowedPositionId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

      final profileResponse = await supabaseClient
          .from('profiles')
          .select('position_id')
          .eq('id', appUser.id)
          .single();
      
      final userPositionId = profileResponse['position_id'];

      // HANYA JIKA posisi cocok, teruskan data user ke AuthGate.
      if (userPositionId == allowedPositionId) {
        return appUser;
      } else {
        // JIKA TIDAK COCOK, anggap saja dia tidak login (kembalikan null)
        // dan paksa logout untuk membersihkan sesi yang salah.
        await supabaseClient.auth.signOut();
        return null;
      }
    } catch (e) {
      // Jika ada error (misal profil tak ada), anggap tidak login.
      return null;
    }
  });
});