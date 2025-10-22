// lib/features/auth/presentation/providers/user_profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:midi_location/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:midi_location/features/profile/domain/entities/profile.dart';
import 'package:midi_location/features/profile/domain/repositories/profile_repository.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(ref.watch(supabaseClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
});

// 2. Provider utama sekarang menjadi bersih dan sederhana
final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final session = client.auth.currentSession;
  if (session == null) {
    print('⚠️ Supabase session is null, user not authenticated');
    throw Exception('User not authenticated');
  }

  return ref.watch(profileRepositoryProvider).getProfileData();
});