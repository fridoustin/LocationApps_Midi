import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';
import 'package:midi_location/features/lokasi/data/datasources/ulok_eksternal_remote_datasource.dart';
import 'package:midi_location/features/lokasi/data/repositories/ulok_eksternal_repository_impl.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_eksternal.dart';
import 'package:midi_location/features/lokasi/domain/repositories/ulok_eksternal_repository.dart';

final ulokEksternalRemoteDataSourceProvider = Provider<UlokEksternalRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return UlokEksternalRemoteDataSource(supabase);
});

final ulokEksternalRepositoryProvider = Provider<UlokEksternalRepository>((ref) {
  final dataSource = ref.watch(ulokEksternalRemoteDataSourceProvider);
  return UlokEksternalRepositoryImpl(dataSource);
});

final ulokEksternalDetailProvider = FutureProvider.family<UlokEksternal, String>((ref, id) async {
  final repository = ref.watch(ulokEksternalRepositoryProvider);
  return repository.getUlokEksternalById(id);
});