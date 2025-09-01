import 'dart:io';
import '../entities/profile.dart';

abstract class ProfileRepository {
  // Mengambil data profil lengkap
  Future<Profile> getProfileData();

  // Memperbarui data profil
  Future<void> updateProfile({
    required String name,
    required String phone,
    File? avatarFile, required String email,
  });
}
