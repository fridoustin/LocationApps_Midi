import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/wilayah/data/datasources/wilayah_remote_datasource.dart';
import 'package:midi_location/features/wilayah/data/repositories/wilayah_repository_impl.dart';
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';
import 'package:midi_location/features/wilayah/domain/repositories/wilayah_repository.dart';

final wilayahDataSourceProvider =
    Provider<WilayahRemoteDataSource>((ref) => WilayahRemoteDataSource());

final wilayahRepositoryProvider = Provider<WilayahRepository>(
  (ref) => WilayahRepositoryImpl(ref.watch(wilayahDataSourceProvider)),
);

// Provinsi
final provincesProvider = FutureProvider<List<WilayahEntity>>((ref) async {
  try {
    return await ref.watch(wilayahRepositoryProvider).getProvinces();
  } catch (e) {
    // debug: hapus/komentari setelah selesai debugging
    // ignore: avoid_print
    print('ERROR fetching provinces: $e');
    return <WilayahEntity>[];
  }
});
final selectedProvinceProvider = StateProvider<WilayahEntity?>((ref) => null);

// Helper kecil untuk cek id valid
bool _hasValidId(WilayahEntity? w) => w != null && (w.id.toString().trim().isNotEmpty);

// Kabupaten/Kota (Regencies)
final regenciesProvider = FutureProvider<List<WilayahEntity>>((ref) async {
  final selectedProvince = ref.watch(selectedProvinceProvider);
  if (!_hasValidId(selectedProvince)) {
    return <WilayahEntity>[]; // jangan panggil API kalau id null/empty
  }

  final provinceId = selectedProvince!.id.toString().trim();
  try {
    return await ref.watch(wilayahRepositoryProvider).getRegencies(provinceId);
  } catch (e) {
    // ignore: avoid_print
    print('ERROR fetching regencies for provinceId=$provinceId: $e');
    return <WilayahEntity>[];
  }
});
final selectedRegencyProvider = StateProvider<WilayahEntity?>((ref) => null);

// Kecamatan (Districts)
final districtsProvider = FutureProvider<List<WilayahEntity>>((ref) async {
  final selectedRegency = ref.watch(selectedRegencyProvider);
  if (!_hasValidId(selectedRegency)) {
    return <WilayahEntity>[];
  }

  final regencyId = selectedRegency!.id.toString().trim();
  try {
    return await ref.watch(wilayahRepositoryProvider).getDistricts(regencyId);
  } catch (e) {
    // ignore: avoid_print
    print('ERROR fetching districts for regencyId=$regencyId: $e');
    return <WilayahEntity>[];
  }
});
final selectedDistrictProvider = StateProvider<WilayahEntity?>((ref) => null);

// Desa/Kelurahan (Villages)
final villagesProvider = FutureProvider<List<WilayahEntity>>((ref) async {
  final selectedDistrict = ref.watch(selectedDistrictProvider);
  if (!_hasValidId(selectedDistrict)) {
    return <WilayahEntity>[];
  }

  final districtId = selectedDistrict!.id.toString().trim();
  try {
    return await ref.watch(wilayahRepositoryProvider).getVillages(districtId);
  } catch (e) {
    // ignore: avoid_print
    print('ERROR fetching villages for districtId=$districtId: $e');
    return <WilayahEntity>[];
  }
});
final selectedVillageProvider = StateProvider<WilayahEntity?>((ref) => null);
