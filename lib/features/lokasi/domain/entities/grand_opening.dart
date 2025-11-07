class GrandOpening {
  final String id;
  final String? progressKpltId;
  final DateTime? tanggalGo;
  final String? rekomGoVendor;
  final DateTime? tglRekomGoVendor;
  final String? finalStatusGo;
  final DateTime? tglSelesaiGo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GrandOpening({
    required this.id,
    this.progressKpltId,
    this.tanggalGo,
    this.rekomGoVendor,
    this.tglRekomGoVendor,
    this.finalStatusGo,
    this.tglSelesaiGo,
    required this.createdAt,
    this.updatedAt,
  });

  factory GrandOpening.fromMap(Map<String, dynamic> map) {
    return GrandOpening(
      id: map['id'] as String,
      progressKpltId: map['progress_kplt_id'] as String?,
      tanggalGo: map['tgl_go'] != null
          ? DateTime.parse(map['tgl_go'] as String)
          : null,
      rekomGoVendor: map['rekom_go_vendor'] as String?,
      tglRekomGoVendor: map['tgl_rekom_go_vendor'] != null
          ? DateTime.parse(map['tgl_rekom_go_vendor'] as String)
          : null,
      finalStatusGo: map['final_status_go'] as String?,
      tglSelesaiGo: map['tgl_selesai_go'] != null
          ? DateTime.parse(map['tgl_selesai_go'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  bool get isCompleted => tglSelesaiGo != null;
}