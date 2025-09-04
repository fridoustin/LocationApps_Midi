import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDataSource {
  final SupabaseClient _client;
  ProfileRemoteDataSource(this._client);

  // Query untuk mengambil data profil dari berbagai tabel
  Future<Map<String, dynamic>> getProfileData() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    final userResponse = await _client
        .from('users')
        .select('*, branch_id, position_id') 
        .eq('id', user.id)
        .single();

    final branchId = userResponse['branch_id'] as String?;
    final positionId = userResponse['position_id'] as String?;

    if (branchId == null || positionId == null) {
      throw Exception('Data profil tidak lengkap (branch atau posisi tidak ada).');
    }

    final branchResponse = await _client
        .from('branch')
        .select('nama')
        .eq('id', branchId)
        .single();

    final positionResponse = await _client
        .from('position')
        .select('nama')
        .eq('id', positionId)
        .single();

    userResponse['branch'] = branchResponse;
    userResponse['positions'] = positionResponse;

    return userResponse;
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String nik,
    File? avatarFile

  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    String? avatarUrl;
    if (avatarFile != null) {
      final fileName = '${user.id}/profile.jpg';
      await _client.storage.from('avatars').upload(
            fileName,
            avatarFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      avatarUrl = _client.storage.from('avatars').getPublicUrl(fileName);
    }

    final updates = {
      'nama': name,
      'no_telp': phone,
      'email': email,
      'nik': nik,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (avatarUrl != null) {
      updates['profile'] = avatarUrl;
    }

    await _client.from('users').update(updates).eq('id', user.id);
  }
}

