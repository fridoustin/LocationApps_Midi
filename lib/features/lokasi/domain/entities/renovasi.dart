import 'package:flutter/material.dart';

class Renovasi {
  final String id;
  final String? progressKpltId;
  final String? kodeStore;
  final String? tipeToko;
  final String? bentukObjek;
  final String? rekomRenovasi;
  final DateTime? tglRekomRenovasi;
  final String? fileRekomRenovasi;
  final DateTime? startSpkRenov;
  final DateTime? endSpkRenov;
  final double? planRenov;
  final double? prosesRenov;
  final double? deviasi;
  final DateTime? tglSerahTerima;
  final String? finalStatusRenov;
  final DateTime? tglSelesaiRenov;
  final DateTime createdAt;
  final DateTime updatedAt;

  Renovasi({
    required this.id,
    this.progressKpltId,
    this.kodeStore,
    this.tipeToko,
    this.bentukObjek,
    this.rekomRenovasi,
    this.tglRekomRenovasi,
    this.fileRekomRenovasi,
    this.startSpkRenov,
    this.endSpkRenov,
    this.planRenov,
    this.prosesRenov,
    this.deviasi,
    this.tglSerahTerima,
    this.finalStatusRenov,
    this.tglSelesaiRenov,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Renovasi.fromMap(Map<String, dynamic> map) {
    return Renovasi(
      id: map['id'] as String,
      progressKpltId: map['progress_kplt_id'] as String?,
      kodeStore: map['kode_store'] as String?,
      tipeToko: map['tipe_toko'] as String?,
      bentukObjek: map['bentuk_objek'] as String?,
      rekomRenovasi: map['rekom_renovasi'] as String?,
      tglRekomRenovasi: map['tgl_rekom_renovasi'] != null
          ? DateTime.parse(map['tgl_rekom_renovasi'] as String)
          : null,
      fileRekomRenovasi: map['file_rekom_renovasi'] as String?,
      startSpkRenov: map['start_spk_renov'] != null
          ? DateTime.parse(map['start_spk_renov'] as String)
          : null,
      endSpkRenov: map['end_spk_renov'] != null
          ? DateTime.parse(map['end_spk_renov'] as String)
          : null,
      planRenov: map['plan_renov'] != null
          ? (map['plan_renov'] as num).toDouble()
          : null,
      prosesRenov: map['proses_renov'] != null
          ? (map['proses_renov'] as num).toDouble()
          : null,
      deviasi: map['deviasi'] != null
          ? (map['deviasi'] as num).toDouble()
          : null,
      tglSerahTerima: map['tgl_serah_terima'] != null
          ? DateTime.parse(map['tgl_serah_terima'] as String)
          : null,
      finalStatusRenov: map['final_status_renov'] as String?,
      tglSelesaiRenov: map['tgl_selesai_renov'] != null
          ? DateTime.parse(map['tgl_selesai_renov'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  bool get isCompleted => tglSelesaiRenov != null;
  
  // Helper untuk menentukan status progress
  String get progressStatus {
    if (prosesRenov == null) return 'Belum Ada Data';
    if (prosesRenov! >= 100) return 'Selesai';
    if (prosesRenov! >= 75) return 'Hampir Selesai';
    if (prosesRenov! >= 50) return 'Setengah Jalan';
    if (prosesRenov! >= 25) return 'Dalam Progress';
    return 'Baru Dimulai';
  }

  // Helper untuk warna progress
  Color get progressColor {
    if (prosesRenov == null) return Colors.grey;
    if (prosesRenov! >= 100) return const Color(0xFF4CAF50); // Green
    if (prosesRenov! >= 75) return const Color(0xFF8BC34A); // Light Green
    if (prosesRenov! >= 50) return const Color(0xFFFFC107); // Amber
    if (prosesRenov! >= 25) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  // Helper untuk status deviasi
  String get deviasiStatus {
    if (deviasi == null) return '-';
    if (deviasi! > 0) return 'Di Atas Target';
    if (deviasi! < 0) return 'Di Bawah Target';
    return 'Sesuai Target';
  }
}

// Entity untuk History Renovasi
class HistoryRenovasi {
  final String id;
  final String? renovasiId;
  final String? kodeStore;
  final String? tipeToko;
  final String? bentukObjek;
  final String? rekomRenovasi;
  final DateTime? tglRekomRenovasi;
  final String? fileRekomRenovasi;
  final DateTime? startSpkRenov;
  final DateTime? endSpkRenov;
  final double? planRenov;
  final double? prosesRenov;
  final double? deviasi;
  final DateTime? tglSerahTerima;
  final String? finalStatusRenov;
  final DateTime? tglSelesaiRenov;
  final DateTime createdAt;
  final DateTime updatedAt;

  HistoryRenovasi({
    required this.id,
    this.renovasiId,
    this.kodeStore,
    this.tipeToko,
    this.bentukObjek,
    this.rekomRenovasi,
    this.tglRekomRenovasi,
    this.fileRekomRenovasi,
    this.startSpkRenov,
    this.endSpkRenov,
    this.planRenov,
    this.prosesRenov,
    this.deviasi,
    this.tglSerahTerima,
    this.finalStatusRenov,
    this.tglSelesaiRenov,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HistoryRenovasi.fromMap(Map<String, dynamic> map) {
    return HistoryRenovasi(
      id: map['id'] as String,
      renovasiId: map['renovasi_id'] as String?,
      kodeStore: map['kode_store'] as String?,
      tipeToko: map['tipe_toko'] as String?,
      bentukObjek: map['bentuk_objek'] as String?,
      rekomRenovasi: map['rekom_renovasi'] as String?,
      tglRekomRenovasi: map['tgl_rekom_renovasi'] != null
          ? DateTime.parse(map['tgl_rekom_renovasi'] as String)
          : null,
      fileRekomRenovasi: map['file_rekom_renovasi'] as String?,
      startSpkRenov: map['start_spk_renov'] != null
          ? DateTime.parse(map['start_spk_renov'] as String)
          : null,
      endSpkRenov: map['end_spk_renov'] != null
          ? DateTime.parse(map['end_spk_renov'] as String)
          : null,
      planRenov: map['plan_renov'] != null
          ? (map['plan_renov'] as num).toDouble()
          : null,
      prosesRenov: map['proses_renov'] != null
          ? (map['proses_renov'] as num).toDouble()
          : null,
      deviasi: map['deviasi'] != null
          ? (map['deviasi'] as num).toDouble()
          : null,
      tglSerahTerima: map['tgl_serah_terima'] != null
          ? DateTime.parse(map['tgl_serah_terima'] as String)
          : null,
      finalStatusRenov: map['final_status_renov'] as String?,
      tglSelesaiRenov: map['tgl_selesai_renov'] != null
          ? DateTime.parse(map['tgl_selesai_renov'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  String get progressStatus {
    if (prosesRenov == null) return 'Belum Ada Data';
    if (prosesRenov! >= 100) return 'Selesai';
    if (prosesRenov! >= 75) return 'Hampir Selesai';
    if (prosesRenov! >= 50) return 'Setengah Jalan';
    if (prosesRenov! >= 25) return 'Dalam Progress';
    return 'Baru Dimulai';
  }

  Color get progressColor {
    if (prosesRenov == null) return Colors.grey;
    if (prosesRenov! >= 100) return const Color(0xFF4CAF50);
    if (prosesRenov! >= 75) return const Color(0xFF8BC34A);
    if (prosesRenov! >= 50) return const Color(0xFFFFC107);
    if (prosesRenov! >= 25) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}