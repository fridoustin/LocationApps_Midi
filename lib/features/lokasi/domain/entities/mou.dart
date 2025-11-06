class Mou {
  final String id;
  final DateTime? tanggalMou;
  final String? namaPemilikFinal;
  final int? periodeSewa;
  final double? nilaiSewa;
  final String? statusPajak;
  final String? pembayaranPph;
  final String? caraPembayaran;
  final int? gracePeriod;
  final double? hargaFinal;
  final String? finalStatusMou;
  final String? progressKpltId;
  final String? keterangan;
  final DateTime? tglSelesaiMou;
  final DateTime createdAt;
  final DateTime updatedAt;

  Mou({
    required this.id,
    this.tanggalMou,
    this.namaPemilikFinal,
    this.periodeSewa,
    this.nilaiSewa,
    this.statusPajak,
    this.pembayaranPph,
    this.caraPembayaran,
    this.gracePeriod,
    this.hargaFinal,
    this.finalStatusMou,
    this.progressKpltId,
    this.keterangan,
    this.tglSelesaiMou,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Mou.fromMap(Map<String, dynamic> map) {
    return Mou(
      id: map['id'] as String,
      tanggalMou: map['tanggal_mou'] != null 
          ? DateTime.parse(map['tanggal_mou'] as String)
          : null,
      namaPemilikFinal: map['nama_pemilik_final'] as String?,
      periodeSewa: map['periode_sewa'] as int?,
      nilaiSewa: map['nilai_sewa'] != null 
          ? (map['nilai_sewa'] as num).toDouble()
          : null,
      statusPajak: map['status_pajak'] as String?,
      pembayaranPph: map['pembayaran_pph'] as String?,
      caraPembayaran: map['cara_pembayaran'] as String?,
      gracePeriod: map['grace_period'] as int?,
      hargaFinal: map['harga_final'] != null
          ? (map['harga_final'] as num).toDouble()
          : null,
      finalStatusMou: map['final_status_mou'] as String?,
      progressKpltId: map['progress_kplt_id'] as String?,
      keterangan: map['keterangan'] as String?,
      tglSelesaiMou: map['tgl_selesai_mou'] != null
          ? DateTime.parse(map['tgl_selesai_mou'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal_mou': tanggalMou?.toIso8601String(),
      'nama_pemilik_final': namaPemilikFinal,
      'periode_sewa': periodeSewa,
      'nilai_sewa': nilaiSewa,
      'status_pajak': statusPajak,
      'pembayaran_pph': pembayaranPph,
      'cara_pembayaran': caraPembayaran,
      'grace_period': gracePeriod,
      'harga_final': hargaFinal,
      'final_status_mou': finalStatusMou,
      'progress_kplt_id': progressKpltId,
      'keterangan': keterangan,
      'tgl_selesai_mou': tglSelesaiMou?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCompleted => tglSelesaiMou != null;
}