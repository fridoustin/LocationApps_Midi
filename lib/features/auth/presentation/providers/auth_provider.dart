// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// Provider untuk SupabaseClient
final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

// Provider untuk AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSource(client);
});

// Provider untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// Provider untuk status autentikasi
// Provider ini akan memberitahu aplikasi kita secara real-time
// apakah ada user yang sedang login atau tidak.
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  // Perhatikan, kita tidak perlu `supabaseClientProvider` lagi di sini!
  return authRepository.onAuthStateChange.asyncMap((appUser) async {
    if (appUser == null) {
      return null;
    }

    // Cukup panggil method dari repository
    final isAllowed = await authRepository.isUserAuthorized(appUser.id);

    if (isAllowed) {
      return appUser;
    } else {
      // Jika tidak diizinkan, pastikan sesi dibersihkan
      // Kita bisa panggil signOut dari repository juga
      await authRepository.signOut();
      return null;
    }
  });
});