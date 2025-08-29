// lib/features/auth/presentation/providers/user_profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/auth_provider.dart';

class UserProfileData {
  final String name;
  final String branchName;
  final String position;
  final String email;

  UserProfileData({required this.name, required this.branchName, required this.position, required this.email});
}

final userProfileProvider = FutureProvider<UserProfileData?>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  try {
    // Inilah query join yang Anda maksud
    final userResponse = await supabase
        .from('users')
        .select('nama, branch_id, position_id, email',)
        .eq('id', user.id)
        .single();

    final userName = userResponse['nama'] as String;
    final branchId = userResponse['branch_id'] as String?;
    final positionId = userResponse['position_id'] as String?;
    final userEmail = userResponse['email'] as String;

    if (branchId == null) {
      throw Exception('User ini tidak memiliki data cabang (branch_id is null).');
    }

    final branchResponse = await supabase
        .from('branch')
        .select('nama')
        .eq('id', branchId)
        .single();

    final positionResponse = await supabase
        .from('position')
        .select('nama')
        .eq('id', positionId as Object)
        .single();
    
    final positionName = positionResponse['nama'] as String;
    final branchName = branchResponse['nama'] as String;
    return UserProfileData(name: userName, branchName: branchName, position: positionName, email: userEmail);

  } catch (e) {
    print('GAGAL QUERY PROFIL DENGAN ERROR: $e');
    throw Exception('Gagal memuat data profil.');
  }
});