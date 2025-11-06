class IzinTetangga {
  final String id;
  final double? nominal;
  final DateTime? tanggalTerbit;
  final String? fileIzinTetangga;
  final String? fileBuktiPembayaran;
  final String? finalStatusIt;
  final String? progressKpltId;
  final DateTime? tglSelesaiIzintetangga;
  final DateTime createdAt;
  final DateTime updatedAt;

  IzinTetangga({
    required this.id,
    this.nominal,
    this.tanggalTerbit,
    this.fileIzinTetangga,
    this.fileBuktiPembayaran,
    this.finalStatusIt,
    this.progressKpltId,
    this.tglSelesaiIzintetangga,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IzinTetangga.fromMap(Map<String, dynamic> map) {
    return IzinTetangga(
      id: map['id'] as String,
      nominal: map['nominal'] != null 
          ? (map['nominal'] as num).toDouble()
          : null,
      tanggalTerbit: map['tanggal_terbit'] != null
          ? DateTime.parse(map['tanggal_terbit'] as String)
          : null,
      fileIzinTetangga: map['file_izin_tetangga'] as String?,
      fileBuktiPembayaran: map['file_bukti_pembayaran'] as String?,
      finalStatusIt: map['final_status_it'] as String?,
      progressKpltId: map['progress_kplt_id'] as String?,
      tglSelesaiIzintetangga: map['tgl_selesai_izintetangga'] != null
          ? DateTime.parse(map['tgl_selesai_izintetangga'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nominal': nominal,
      'tanggal_terbit': tanggalTerbit?.toIso8601String(),
      'file_izin_tetangga': fileIzinTetangga,
      'file_bukti_pembayaran': fileBuktiPembayaran,
      'final_status_it': finalStatusIt,
      'progress_kplt_id': progressKpltId,
      'tgl_selesai_izintetangga': tglSelesaiIzintetangga?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCompleted => tglSelesaiIzintetangga != null;
}