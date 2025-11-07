class Notaris {
  final String id;
  final String? progressKpltId;
  final String? filePar;
  final DateTime? tglPar;
  final String? validasiLegal;
  final DateTime? tglValidasiLegal;
  final String? statusNotaris;
  final DateTime? tglPlanNotaris;
  final DateTime? tglNotaris;
  final String? statusPembayaran;
  final DateTime? tglPembayaran;
  final String? finalStatusNotaris;
  final DateTime? tglSelesaiNotaris;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Notaris({
    required this.id,
    this.progressKpltId,
    this.filePar,
    this.tglPar,
    this.validasiLegal,
    this.tglValidasiLegal,
    this.statusNotaris,
    this.tglPlanNotaris,
    this.tglNotaris,
    this.statusPembayaran,
    this.tglPembayaran,
    this.finalStatusNotaris,
    this.tglSelesaiNotaris,
    required this.createdAt,
    this.updatedAt,
  });

  factory Notaris.fromMap(Map<String, dynamic> map) {
    return Notaris(
      id: map['id'] as String,
      progressKpltId: map['progress_kplt_id'] as String?,
      filePar: map['par_online'] as String?,
      tglPar: map['tanggal_par'] != null
          ? DateTime.parse(map['tanggal_par'] as String)
          : null,
      validasiLegal: map['validasi_legal'] as String?,
      tglValidasiLegal: map['tanggal_validasi_legal'] != null
          ? DateTime.parse(map['tanggal_validasi_legal'] as String)
          : null,
      statusNotaris: map['status_notaris'] as String?,
      tglPlanNotaris: map['tanggal_plan_notaris'] != null
          ? DateTime.parse(map['tanggal_plan_notaris'] as String)
          : null,
      tglNotaris: map['tanggal_notaris'] != null
          ? DateTime.parse(map['tanggal_notaris'] as String)
          : null,
      statusPembayaran: map['status_pembayaran'] as String?,
      tglPembayaran: map['tanggal_pembayaran'] != null
          ? DateTime.parse(map['tanggal_pembayaran'] as String)
          : null,
      finalStatusNotaris: map['final_status_notaris'] as String?,
      tglSelesaiNotaris: map['tgl_selesai_notaris'] != null
          ? DateTime.parse(map['tgl_selesai_notaris'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  bool get isCompleted => tglSelesaiNotaris != null;
}

class HistoryNotaris {
  final String id;
  final String notarisId;
  final String? filePar;
  final DateTime? tglPar;
  final String? validasiLegal;
  final DateTime? tglValidasiLegal;
  final String? statusNotaris;
  final DateTime? tglPlanNotaris;
  final DateTime? tglNotaris;
  final String? statusPembayaran;
  final DateTime? tglPembayaran;
  final String? finalStatusNotaris;
  final DateTime createdAt;
  final DateTime? tglSelesai;
  
  HistoryNotaris({
    required this.id,
    required this.notarisId,
    this.filePar,
    this.tglPar,
    this.validasiLegal,
    this.tglValidasiLegal,
    this.statusNotaris,
    this.tglPlanNotaris,
    this.tglNotaris,
    this.statusPembayaran,
    this.tglPembayaran,
    this.finalStatusNotaris,
    required this.createdAt,
    this.tglSelesai,
  });

  factory HistoryNotaris.fromMap(Map<String, dynamic> map) {
    return HistoryNotaris(
      id: map['id'] as String,
      notarisId: map['notaris_id'] as String,
      filePar: map['par_online'] as String?,
      tglPar: map['tanggal_par'] != null
          ? DateTime.parse(map['tanggal_par'] as String)
          : null,
      validasiLegal: map['validasi_legal'] as String?,
      tglValidasiLegal: map['tanggal_validasi_legal'] != null
          ? DateTime.parse(map['tanggal_validasi_legal'] as String)
          : null,
      statusNotaris: map['status_notaris'] as String?,
      tglPlanNotaris: map['tanggal_plan_notaris'] != null
          ? DateTime.parse(map['tanggal_plan_notaris'] as String)
          : null,
      tglNotaris: map['tanggal_notaris'] != null
          ? DateTime.parse(map['tanggal_notaris'] as String)
          : null,
      statusPembayaran: map['status_pembayaran'] as String?,
      tglPembayaran: map['tanggal_pembayaran'] != null
          ? DateTime.parse(map['tanggal_pembayaran'] as String)
          : null,
      finalStatusNotaris: map['final_status_notaris'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      tglSelesai: map['tgl_selesai'] != null
          ? DateTime.parse(map['tgl_selesai'] as String)
          : null,
    );
  }
}