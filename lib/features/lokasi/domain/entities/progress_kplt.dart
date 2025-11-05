enum ProgressKpltStatus {
  notStarted,
  mou,
  izinTetangga,
  perizinan,
  notaris,
  renovasi,
  grandOpening;

  String get value {
    switch (this) {
      case ProgressKpltStatus.notStarted:
        return 'not_started';
      case ProgressKpltStatus.mou:
        return 'mou';
      case ProgressKpltStatus.izinTetangga:
        return 'izin_tetangga';
      case ProgressKpltStatus.perizinan:
        return 'perizinan';
      case ProgressKpltStatus.notaris:
        return 'notaris';
      case ProgressKpltStatus.renovasi:
        return 'renovasi';
      case ProgressKpltStatus.grandOpening:
        return 'grand_opening';
    }
  }

  static ProgressKpltStatus fromString(String value) {
    switch (value) {
      case 'not_started':
        return ProgressKpltStatus.notStarted;
      case 'mou':
        return ProgressKpltStatus.mou;
      case 'izin_tetangga':
        return ProgressKpltStatus.izinTetangga;
      case 'perizinan':
        return ProgressKpltStatus.perizinan;
      case 'notaris':
        return ProgressKpltStatus.notaris;
      case 'renovasi':
        return ProgressKpltStatus.renovasi;
      case 'grand_opening':
        return ProgressKpltStatus.grandOpening;
      default:
        return ProgressKpltStatus.notStarted;
    }
  }
}

class ProgressKplt {
  final String id;
  final String kpltId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ProgressKpltStatus status;
  final String? kpltNama;
  final String? kpltAlamat;
  final String? kpltKecamatan;
  final String? kpltKabupaten;
  final String? kpltProvinsi;
  final String? kpltKelurahan;
  final int? computedPercentage;

  ProgressKplt({
    required this.id,
    required this.kpltId,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    this.kpltNama,
    this.kpltAlamat,
    this.kpltKecamatan,
    this.kpltKabupaten,
    this.kpltProvinsi,
    this.kpltKelurahan,
    this.computedPercentage,
  });

  factory ProgressKplt.fromMap(Map<String, dynamic> map) {
    final kpltData = map['kplt'] as Map<String, dynamic>?;
    
    return ProgressKplt(
      id: map['id'] as String,
      kpltId: map['kplt_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
      status: ProgressKpltStatus.fromString(
        map['status'] as String? ?? 'not_started'
      ),
      kpltNama: kpltData?['nama_kplt'] as String?,
      kpltAlamat: kpltData?['alamat'] as String?,
      kpltKecamatan: kpltData?['kecamatan'] as String?,
      kpltKabupaten: kpltData?['kabupaten'] as String?,
      kpltProvinsi: kpltData?['provinsi'] as String?,
      kpltKelurahan: kpltData?['desa_kelurahan'] as String?,
      computedPercentage: map['computed_percentage'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kplt_id': kpltId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status.value,
    };
  }

  ProgressKplt copyWith({
    String? id,
    String? kpltId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProgressKpltStatus? status,
    String? kpltNama,
    String? kpltAlamat,
    String? kpltKecamatan,
    String? kpltKabupaten,
    String? kpltProvinsi,
    String? kpltKelurahan,
    int? computedPercentage,
  }) {
    return ProgressKplt(
      id: id ?? this.id,
      kpltId: kpltId ?? this.kpltId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      kpltNama: kpltNama ?? this.kpltNama,
      kpltAlamat: kpltAlamat ?? this.kpltAlamat,
      kpltKecamatan: kpltKecamatan ?? this.kpltKecamatan,
      kpltKabupaten: kpltKabupaten ?? this.kpltKabupaten,
      kpltProvinsi: kpltProvinsi ?? this.kpltProvinsi,
      kpltKelurahan: kpltKelurahan ?? this.kpltKelurahan,
      computedPercentage: computedPercentage ?? this.computedPercentage,
    );
  }
  
  String get fullAddress {
    final parts = <String>[];
    if (kpltAlamat != null) parts.add(kpltAlamat!);
    if (kpltKecamatan != null) parts.add('Kec. $kpltKecamatan');
    if (kpltKabupaten != null) parts.add(kpltKabupaten!);
    if (kpltProvinsi != null) parts.add(kpltProvinsi!);
    return parts.join(', ');
  }
}

extension ProgressKpltExtension on ProgressKplt {
  String get readableStatus {
    switch (status) {
      case ProgressKpltStatus.notStarted:
        return 'Belum Dimulai';
      case ProgressKpltStatus.mou:
        return 'Proses MOU';
      case ProgressKpltStatus.izinTetangga:
        return 'Proses Izin Tetangga';
      case ProgressKpltStatus.perizinan:
        return 'Proses Perizinan';
      case ProgressKpltStatus.notaris:
        return 'Proses Notaris';
      case ProgressKpltStatus.renovasi:
        return 'Proses Renovasi';
      case ProgressKpltStatus.grandOpening:
        return 'Grand Opening';
    }
  }

  bool get isCompleted => status == ProgressKpltStatus.grandOpening;
  bool get isNotStarted => status == ProgressKpltStatus.notStarted;
  
  int get progressPercentage {
    return computedPercentage ?? 0;
  }
}

class ProgressCalculator {
  static int calculatePercentage(Map<String, dynamic> completionData) {
    int completed = 0;
    const total = 6; 
    
    if (completionData['mou']?['completed'] == true) completed++;
    if (completionData['izin_tetangga']?['completed'] == true) completed++;
    if (completionData['perizinan']?['completed'] == true) completed++;
    if (completionData['notaris']?['completed'] == true) completed++;
    if (completionData['renovasi']?['completed'] == true) completed++;
    if (completionData['grand_opening']?['completed'] == true) completed++;
    
    return ((completed / total) * 100).round();
  }
  
  static String determineCurrentStatus(Map<String, dynamic> completionData) {
    if (completionData['grand_opening']?['completed'] == true) {
      return 'grand_opening';
    }
    if (completionData['renovasi']?['completed'] == true) {
      return 'renovasi';
    }
    if (completionData['notaris']?['completed'] == true) {
      return 'notaris';
    }
    final izinCompleted = completionData['izin_tetangga']?['completed'] == true;
    final perizinanCompleted = completionData['perizinan']?['completed'] == true;
    
    if (izinCompleted && perizinanCompleted) {
      return 'perizinan'; 
    } else if (izinCompleted || perizinanCompleted) {
      return 'perizinan'; 
    }
    
    if (completionData['mou']?['completed'] == true) {
      return 'mou';
    }
    
    return 'not_started';
  }
}