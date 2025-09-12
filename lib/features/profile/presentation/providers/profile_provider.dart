import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

// Sediakan instance dari DataSource dan Repository khusus profil
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(ref.watch(supabaseClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
});

// Provider untuk mengambil data profil lengkap untuk UI
final profileDataProvider = FutureProvider.autoDispose<Profile>((ref) { 
  final profileRepository = ref.watch(profileRepositoryProvider);
  return profileRepository.getProfileData();
});

