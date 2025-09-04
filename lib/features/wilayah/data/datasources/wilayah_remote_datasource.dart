// wilayah_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';

class WilayahRemoteDataSource {
  /// Base URL untuk wilayah.id API
  final String baseUrl;
  final http.Client client;

  WilayahRemoteDataSource({
    this.baseUrl = 'https://wilayah.id/api',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<WilayahEntity>> getProvinces() async {
    final uri = Uri.parse('$baseUrl/provinces.json');
    return _fetchAndParseList(uri);
  }

  Future<List<WilayahEntity>> getRegencies(String provinceCode) async {
    final uri = Uri.parse('$baseUrl/regencies/$provinceCode.json');
    return _fetchAndParseList(uri);
  }

  Future<List<WilayahEntity>> getDistricts(String regencyCode) async {
    final uri = Uri.parse('$baseUrl/districts/$regencyCode.json');
    return _fetchAndParseList(uri);
  }

  Future<List<WilayahEntity>> getVillages(String districtCode) async {
    final uri = Uri.parse('$baseUrl/villages/$districtCode.json');
    return _fetchAndParseList(uri);
  }

  // -------------------------
  Future<List<WilayahEntity>> _fetchAndParseList(Uri uri) async {
    final resp = await client.get(uri).timeout(const Duration(seconds: 15));

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} saat mengakses ${uri.toString()}');
    }

    final body = resp.body;
    if (body.trim().isEmpty) return <WilayahEntity>[];

    final decoded = json.decode(body);

    // 1) Jika response adalah list langsung (paling mungkin untuk endpoint wilayah.id)
    if (decoded is List) {
      return decoded.map<WilayahEntity>((e) => _mapToEntity(e)).toList();
    }

    // 2) Jika response adalah map (bungkusan), cari list di beberapa key umum
    if (decoded is Map) {
      final candidates = ['data', 'results', 'items', 'docs', 'rows', 'records'];
      for (final key in candidates) {
        final maybe = decoded[key];
        if (maybe is List) {
          return maybe.map<WilayahEntity>((e) => _mapToEntity(e)).toList();
        }
      }

      // Kadang value pertama map adalah list
      final firstListInValues = decoded.values.firstWhere(
        (v) => v is List,
        orElse: () => null,
      );
      if (firstListInValues is List) {
        return firstListInValues.map<WilayahEntity>((e) => _mapToEntity(e)).toList();
      }

      // Jika map itu mewakili satu entity (mis. { "id": "...", "name": "..." }),
      // bungkus jadi list satu elemen
      if (_looksLikeEntityMap(decoded)) {
        return [_mapToEntity(decoded)];
      }
    }

    throw Exception('Unexpected response format (${decoded.runtimeType}) from ${uri.toString()}');
  }

  // Convert dynamic -> WilayahEntity
  WilayahEntity _mapToEntity(dynamic e) {
    if (e is WilayahEntity) return e;

    if (e is Map) {
      final m = Map<String, dynamic>.from(e);
      // PENTING: sesuaikan kalau factory/konstuktormu bernama lain
      // Saya asumsikan ada WilayahEntity.fromJson(Map<String,dynamic>)
      try {
        return WilayahEntity.fromJson(m);
      } catch (_) {
        // fallback: coba ambil key umum
        final id = (m['id'] ?? m['kode'] ?? m['code'] ?? m['value'] ?? '').toString();
        final name = (m['name'] ?? m['nama'] ?? m['title'] ?? '').toString();
        return WilayahEntity(id: id, name: name);
      }
    }

    // fallback, jika e adalah string/number
    return WilayahEntity(id: e.toString(), name: e.toString());
  }

  bool _looksLikeEntityMap(Map m) {
    final lowerKeys = m.keys.map((k) => k.toString().toLowerCase()).toSet();
    return lowerKeys.contains('id') || lowerKeys.contains('name') || lowerKeys.contains('nama') || lowerKeys.contains('kode');
  }
}
