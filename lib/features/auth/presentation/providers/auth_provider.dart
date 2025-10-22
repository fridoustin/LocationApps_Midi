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

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final supabaseClient = ref.watch(supabaseClientProvider);

  return authRepository.onAuthStateChange.asyncMap((appUser) async {
    try {
      if (appUser == null) {
        return null;
      }

      final isAllowed = await authRepository.isUserAuthorized(appUser.id);
      if (isAllowed) {
        return appUser;
      } else {
        final session = supabaseClient.auth.currentSession;
        if (session != null) {
          try {
            await authRepository.signOut();
          } catch (_) {}
        }
        return null;
      }
    } catch (e) {
      final session = supabaseClient.auth.currentSession;
      if (session != null) {
        try {
          await authRepository.signOut();
        } catch (_) {}
      }
      return null;
    }
  }).handleError((_) {
  });
});