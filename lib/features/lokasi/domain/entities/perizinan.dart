class Perizinan {
  final String id;
  final String? progressKpltId;
  final String? fileSph;
  final DateTime? tglSph;
  final double? nominalSph;
  final String? statusBerkas;
  final DateTime? tglStBerkas;
  final String? fileBuktiSt;
  final String? statusGambarDenah;
  final DateTime? tglGambarDenah;
  final String? fileDenah;
  final String? oss;
  final DateTime? tglOss;
  final String? statusSpk;
  final String? fileSpk;
  final DateTime? tglSpk;
  final String? rekomNotarisVendor;
  final DateTime? tglRekomNotaris;
  final String? fileRekomNotaris;
  final String? finalStatusPerizinan;
  final DateTime? tglSelesaiPerizinan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Perizinan({
    required this.id,
    this.progressKpltId,
    this.fileSph,
    this.tglSph,
    this.nominalSph,
    this.statusBerkas,
    this.tglStBerkas,
    this.fileBuktiSt,
    this.statusGambarDenah,
    this.tglGambarDenah,
    this.fileDenah,
    this.oss,
    this.tglOss,
    this.statusSpk,
    this.fileSpk,
    this.tglSpk,
    this.rekomNotarisVendor,
    this.tglRekomNotaris,
    this.fileRekomNotaris,
    this.finalStatusPerizinan,
    this.tglSelesaiPerizinan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Perizinan.fromMap(Map<String, dynamic> map) {
    return Perizinan(
      id: map['id'] as String,
      progressKpltId: map['progress_kplt_id'] as String?,
      fileSph: map['file_sph'] as String?,
      tglSph: map['tgl_sph'] != null
          ? DateTime.parse(map['tgl_sph'] as String)
          : null,
      nominalSph: map['nominal_sph'] != null
          ? (map['nominal_sph'] as num).toDouble()
          : null,
      statusBerkas: map['status_berkas'] as String?,
      tglStBerkas: map['tgl_st_berkas'] != null
          ? DateTime.parse(map['tgl_st_berkas'] as String)
          : null,
      fileBuktiSt: map['file_bukti_st'] as String?,
      statusGambarDenah: map['status_gambar_denah'] as String?,
      tglGambarDenah: map['tgl_gambar_denah'] != null
          ? DateTime.parse(map['tgl_gambar_denah'] as String)
          : null,
      fileDenah: map['file_denah'] as String?,
      oss: map['oss'] as String?,
      tglOss: map['tgl_oss'] != null
          ? DateTime.parse(map['tgl_oss'] as String)
          : null,
      statusSpk: map['status_spk'] as String?,
      fileSpk: map['file_spk'] as String?,
      tglSpk: map['tgl_spk'] != null
          ? DateTime.parse(map['tgl_spk'] as String)
          : null,
      rekomNotarisVendor: map['rekom_notaris_vendor'] as String?,
      tglRekomNotaris: map['tgl_rekom_notaris'] != null
          ? DateTime.parse(map['tgl_rekom_notaris'] as String)
          : null,
      fileRekomNotaris: map['file_rekom_notaris'] as String?,
      finalStatusPerizinan: map['final_status_perizinan'] as String?,
      tglSelesaiPerizinan: map['tgl_selesai_perizinan'] != null
          ? DateTime.parse(map['tgl_selesai_perizinan'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  bool get isCompleted => tglSelesaiPerizinan != null;
}

// Entity untuk History Perizinan
class HistoryPerizinan {
  final String id;
  final String? perizinanId;
  final String? fileSph;
  final DateTime? tglSph;
  final double? nominalSph;
  final String? statusBerkas;
  final DateTime? tglStBerkas;
  final String? fileBuktiSt;
  final String? statusGambarDenah;
  final DateTime? tglGambarDenah;
  final String? fileDenah;
  final String? oss;
  final DateTime? tglOss;
  final String? statusSpk;
  final String? fileSpk;
  final DateTime? tglSpk;
  final String? rekomNotarisVendor;
  final DateTime? tglRekomNotaris;
  final String? fileRekomNotaris;
  final DateTime createdAt;
  final DateTime updatedAt;

  HistoryPerizinan({
    required this.id,
    this.perizinanId,
    this.fileSph,
    this.tglSph,
    this.nominalSph,
    this.statusBerkas,
    this.tglStBerkas,
    this.fileBuktiSt,
    this.statusGambarDenah,
    this.tglGambarDenah,
    this.fileDenah,
    this.oss,
    this.tglOss,
    this.statusSpk,
    this.fileSpk,
    this.tglSpk,
    this.rekomNotarisVendor,
    this.tglRekomNotaris,
    this.fileRekomNotaris,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HistoryPerizinan.fromMap(Map<String, dynamic> map) {
    return HistoryPerizinan(
      id: map['id'] as String,
      perizinanId: map['perizinan_id'] as String?,
      fileSph: map['file_sph'] as String?,
      tglSph: map['tgl_sph'] != null
          ? DateTime.parse(map['tgl_sph'] as String)
          : null,
      nominalSph: map['nominal_sph'] != null
          ? (map['nominal_sph'] as num).toDouble()
          : null,
      statusBerkas: map['status_berkas'] as String?,
      tglStBerkas: map['tgl_st_berkas'] != null
          ? DateTime.parse(map['tgl_st_berkas'] as String)
          : null,
      fileBuktiSt: map['file_bukti_st'] as String?,
      statusGambarDenah: map['status_gambar_denah'] as String?,
      tglGambarDenah: map['tgl_gambar_denah'] != null
          ? DateTime.parse(map['tgl_gambar_denah'] as String)
          : null,
      fileDenah: map['file_denah'] as String?,
      oss: map['oss'] as String?,
      tglOss: map['tgl_oss'] != null
          ? DateTime.parse(map['tgl_oss'] as String)
          : null,
      statusSpk: map['status_spk'] as String?,
      fileSpk: map['file_spk'] as String?,
      tglSpk: map['tgl_spk'] != null
          ? DateTime.parse(map['tgl_spk'] as String)
          : null,
      rekomNotarisVendor: map['rekom_notaris_vendor'] as String?,
      tglRekomNotaris: map['tgl_rekom_notaris'] != null
          ? DateTime.parse(map['tgl_rekom_notaris'] as String)
          : null,
      fileRekomNotaris: map['file_rekom_notaris'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}