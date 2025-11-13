// lib/core/utils/json_converters.dart
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

class LatLngConverter implements JsonConverter<LatLng?, Map<String, double>?> {
  const LatLngConverter();

  @override
  LatLng? fromJson(Map<String, double>? json) {
    if (json == null) return null;
    final lat = json['latitude'];
    final lng = json['longitude'];
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  Map<String, double>? toJson(LatLng? object) {
    if (object == null) return null;
    return {'latitude': object.latitude, 'longitude': object.longitude};
  }
}

class FilePathConverter implements JsonConverter<File?, String?> {
  const FilePathConverter();

  @override
  File? fromJson(String? json) {
    if (json == null) return null;
    return File(json);
  }

  @override
  String? toJson(File? object) => object?.path;
}

class DateTimeIsoConverter implements JsonConverter<DateTime?, String?> {
  const DateTimeIsoConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null) return null;
    try {
      return DateTime.parse(json);
    } catch (_) {
      return null;
    }
  }

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}