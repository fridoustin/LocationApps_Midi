import 'dart:io';
import '../../domain/entities/profile.dart'; // Nanti kita akan buat/perbarui file ini
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;
  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<Profile> getProfileData() async {
    final data = await _dataSource.getProfileData();
    // Ubah data Map dari Supabase menjadi objek Profile
    return Profile(
      id: data['id'],
      name: data['nama'],
      email: data['email'],
      phone: data['no_telp'] ?? '-',
      position: (data['positions'] as Map<String, dynamic>)['nama'],
      branch: (data['branch'] as Map<String, dynamic>)['nama'],
      avatarUrl: data['profile'],
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    File? avatarFile,
  }) {
    return _dataSource.updateProfile(
      name: name,
      email: email,
      phone: phone,
      avatarFile: avatarFile,
    );
  }
}

