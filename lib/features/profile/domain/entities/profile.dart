
class Profile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String position;
  final String branch;
  final String branchId;
  final String? avatarUrl;
  final String? nik;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.position,
    required this.branch,
    required this.branchId,
    this.avatarUrl,
    this.nik
  });
}
