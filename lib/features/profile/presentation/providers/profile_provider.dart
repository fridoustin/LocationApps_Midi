import 'package:flutter_riverpod/flutter_riverpod.dart';

class Profile {
  String name;
  String email;
  String phone;
  String role;
  String branch;

  Profile({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.branch,
  });

  Profile copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? branch,
  }) {
    return Profile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      branch: branch ?? this.branch,
    );
  }
}

class ProfileNotifier extends StateNotifier<Profile> {
  ProfileNotifier()
    : super(
        Profile(
          name: "Apriyanto Dwi Herlambang",
          email: "email@mu.co.id",
          phone: "+62 812 - 1234 - 1244",
          role: "Location Manager",
          branch: "Head Office",
        ),
      );

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? branch,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      phone: phone,
      role: role,
      branch: branch,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile>(
  (ref) => ProfileNotifier(),
);
