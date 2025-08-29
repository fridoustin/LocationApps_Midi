// lib/features/auth/presentation/providers/user_profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';

class UserProfileData {
  final String name;
  final String branchName;

  UserProfileData({required this.name, required this.branchName});
}

final userProfileProvider = FutureProvider<UserProfileData?>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  try {
    // Inilah query join yang Anda maksud
    final userResponse = await supabase
        .from('users')
        .select('nama, branch_id')
        .eq('id', user.id)
        .single();

    final userName = userResponse['nama'] as String;
    final branchId = userResponse['branch_id'] as String?;

    if (branchId == null) {
      throw Exception('User ini tidak memiliki data cabang (branch_id is null).');
    }

    final branchResponse = await supabase
        .from('branch')
        .select('nama')
        .eq('id', branchId)
        .single();
    
    final branchName = branchResponse['nama'] as String;
    return UserProfileData(name: userName, branchName: branchName);

  } catch (e) {
    print('GAGAL QUERY PROFIL DENGAN ERROR: $e');
    throw Exception('Gagal memuat data profil.');
  }
});