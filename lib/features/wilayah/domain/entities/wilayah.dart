// wilayah.dart
class WilayahEntity {
  final String id;
  final String name;

  WilayahEntity({required this.id, required this.name});

  factory WilayahEntity.fromJson(Map<String, dynamic> json) {
    final rawId = json['code'] ?? json['id'] ?? json['kode'] ?? json['value'] ?? '';
    final id = rawId?.toString().trim() ?? '';

    final rawName = json['name'] ?? json['nama'] ?? json['title'] ?? '';
    final name = rawName?.toString().trim() ?? '';

    return WilayahEntity(id: id, name: name);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => 'WilayahEntity(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WilayahEntity && runtimeType == other.runtimeType && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
