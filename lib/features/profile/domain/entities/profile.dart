
class Profile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String position;
  final String branch;
  final String? avatarUrl;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.position,
    required this.branch,
    this.avatarUrl,
  });
}
