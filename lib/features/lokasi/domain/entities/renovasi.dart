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
  
  double? get percentageComplete {
    if (planRenov == null || planRenov == 0) return null;
    if (prosesRenov == null) return 0;
    return (prosesRenov! / planRenov!) * 100;
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

  double? get percentageComplete {
    if (planRenov == null || planRenov == 0) return null;
    if (prosesRenov == null) return 0;
    return (prosesRenov! / planRenov!) * 100;
  }
}