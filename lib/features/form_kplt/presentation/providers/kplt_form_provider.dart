import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_data.dart';
import 'package:midi_location/features/form_kplt/domain/repositories/kplt_repository.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';

enum KpltFormStatus { initial, loading, success, error }

class KpltFormState extends Equatable {
  final KpltFormStatus status;
  final String? errorMessage;
  final String ulokId;
  final String? branchId;
  final String? karakterLokasi;
  final String? sosialEkonomi;
  final String? peStatus;
  final double? skorFpl;
  final double? std;
  final double? apc;
  final double? spd;
  final double? peRab;
  final File? pdfFoto;
  final File? countingKompetitor;
  final File? pdfPembanding;
  final File? pdfKks;
  final File? excelFpl;
  final File? excelPe;
  final File? pdfFormUkur;
  final File? videoTrafficSiang;
  final File? videoTrafficMalam;
  final File? video360Siang;
  final File? video360Malam;
  final File? petaCoverage;

  const KpltFormState({
    required this.status,
    required this.ulokId,
    this.errorMessage,
    this.branchId,
    this.karakterLokasi,
    this.sosialEkonomi,
    this.peStatus,
    this.skorFpl,
    this.std,
    this.apc,
    this.spd,
    this.peRab,
    this.pdfFoto,
    this.countingKompetitor,
    this.pdfPembanding,
    this.pdfKks,
    this.excelFpl,
    this.excelPe,
    this.pdfFormUkur,
    this.videoTrafficSiang,
    this.videoTrafficMalam,
    this.video360Siang,
    this.video360Malam,
    this.petaCoverage,
  });

  // State awal saat form pertama kali dibuka
  factory KpltFormState.initial({required String ulokId}) {
    return KpltFormState(status: KpltFormStatus.initial, ulokId: ulokId);
  }

  // Method copyWith untuk update state dengan mudah
  KpltFormState copyWith({
    KpltFormStatus? status,
    String? errorMessage,
    String? branchId,
    String? karakterLokasi,
    String? sosialEkonomi,
    String? peStatus,
    double? skorFpl,
    double? std,
    double? apc,
    double? spd,
    double? peRab,
    File? pdfFoto,
    File? countingKompetitor,
    File? pdfPembanding,
    File? pdfKks,
    File? excelFpl,
    File? excelPe,
    File? pdfFormUkur,
    File? videoTrafficSiang,
    File? videoTrafficMalam,
    File? video360Siang,
    File? video360Malam,
    File? petaCoverage,
  }) {
    return KpltFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      ulokId: ulokId,
      branchId: branchId ?? this.branchId,
      karakterLokasi: karakterLokasi ?? this.karakterLokasi,
      sosialEkonomi: sosialEkonomi ?? this.sosialEkonomi,
      peStatus: peStatus ?? this.peStatus,
      skorFpl: skorFpl ?? this.skorFpl,
      std: std ?? this.std,
      apc: apc ?? this.apc,
      spd: spd ?? this.spd,
      peRab: peRab ?? this.peRab,
      pdfFoto: pdfFoto ?? this.pdfFoto,
      countingKompetitor: countingKompetitor ?? this.countingKompetitor,
      pdfPembanding: pdfPembanding ?? this.pdfPembanding,
      pdfKks: pdfKks ?? this.pdfKks,
      excelFpl: excelFpl ?? this.excelFpl,
      excelPe: excelPe ?? this.excelPe,
      pdfFormUkur: pdfFormUkur ?? this.pdfFormUkur,
      videoTrafficSiang: videoTrafficSiang ?? this.videoTrafficSiang,
      videoTrafficMalam: videoTrafficMalam ?? this.videoTrafficMalam,
      video360Siang: video360Siang ?? this.video360Siang,
      video360Malam: video360Malam ?? this.video360Malam,
      petaCoverage: petaCoverage ?? this.petaCoverage,
    );
  }
  
  @override
  List<Object?> get props => [status, errorMessage, ulokId, branchId, karakterLokasi, sosialEkonomi, peStatus, skorFpl, std, apc, spd, peRab, pdfFoto, countingKompetitor, pdfPembanding, pdfKks, excelFpl, excelPe, pdfFormUkur, videoTrafficSiang, videoTrafficMalam, video360Siang, video360Malam, petaCoverage];
}

class KpltFormNotifier extends StateNotifier<KpltFormState> {
  final KpltRepository _repository;

  KpltFormNotifier(this._repository, {required String ulokId}) 
      : super(KpltFormState.initial(ulokId: ulokId));

  void onBranchChanged(String value) {
    state = state.copyWith(branchId: value);
  }

  void onKarakterLokasiChanged(String value) {
    state = state.copyWith(karakterLokasi: value);
  }
  
  void onSosialEkonomiChanged(String value) {
    state = state.copyWith(sosialEkonomi: value);
  }

  void onPeStatusChanged(String value) {
    state = state.copyWith(peStatus: value);
  }

  void onSkorFplChanged(String value) {
    state = state.copyWith(skorFpl: double.tryParse(value));
  }

  void onStdChanged(String value) {
    state = state.copyWith(std: double.tryParse(value));
  }
  
  void onApcChanged(String value) {
    state = state.copyWith(apc: double.tryParse(value));
  }
  
  void onSpdChanged(String value) {
    state = state.copyWith(spd: double.tryParse(value));
  }

  void onPeRabChanged(String value) {
    state = state.copyWith(peRab: double.tryParse(value));
  }

  void onFilePicked(String fieldName, File file) {
    switch (fieldName) {
      case 'pdfFoto':
        state = state.copyWith(pdfFoto: file);
        break;
      case 'countingKompetitor':
        state = state.copyWith(countingKompetitor: file);
        break;
      case 'pdfPembanding':
        state = state.copyWith(pdfPembanding: file);
        break;
      case 'pdfKks':
        state = state.copyWith(pdfKks: file);
        break;
      case 'excelFpl':
        state = state.copyWith(excelFpl: file);
        break;
      case 'excelPe':
        state = state.copyWith(excelPe: file);
        break;
      case 'pdfFormUkur':
        state = state.copyWith(pdfFormUkur: file);
        break;
      case 'videoTrafficSiang':
        state = state.copyWith(videoTrafficSiang: file);
        break;
      case 'videoTrafficMalam':
        state = state.copyWith(videoTrafficMalam: file);
        break;
      case 'video360Siang':
        state = state.copyWith(video360Siang: file);
        break;
      case 'video360Malam':
        state = state.copyWith(video360Malam: file);
        break;
      case 'petaCoverage':
        state = state.copyWith(petaCoverage: file);
        break;
    }
  }

  // --- Method utama untuk submit form ---
  Future<void> submitForm() async {
    final s = state; 
    if (s.branchId == null || s.karakterLokasi == null || s.sosialEkonomi == null ||
        s.peStatus == null || s.skorFpl == null || s.std == null || s.apc == null ||
        s.spd == null || s.peRab == null || s.pdfFoto == null || s.countingKompetitor == null ||
        s.pdfPembanding == null || s.pdfKks == null || s.excelFpl == null || s.excelPe == null ||
        s.pdfFormUkur == null || s.videoTrafficSiang == null || s.videoTrafficMalam == null ||
        s.video360Siang == null || s.video360Malam == null || s.petaCoverage == null)
    {
      state = state.copyWith(status: KpltFormStatus.error, errorMessage: 'Harap lengkapi semua data.');
      state = state.copyWith(status: KpltFormStatus.initial, errorMessage: null);
      return;
    }

    state = state.copyWith(status: KpltFormStatus.loading);

    try {
      final formData = KpltFormData(
        ulokId: s.ulokId,
        branchId: s.branchId!,
        karakterLokasi: s.karakterLokasi!,
        sosialEkonomi: s.sosialEkonomi!,
        peStatus: s.peStatus!,
        skorFpl: s.skorFpl!,
        std: s.std!,
        apc: s.apc!,
        spd: s.spd!,
        peRab: s.peRab!,
        pdfFoto: s.pdfFoto!,
        countingKompetitor: s.countingKompetitor!,
        pdfPembanding: s.pdfPembanding!,
        pdfKks: s.pdfKks!,
        excelFpl: s.excelFpl!,
        excelPe: s.excelPe!,
        pdfFormUkur: s.pdfFormUkur!,
        videoTrafficSiang: s.videoTrafficSiang!,
        videoTrafficMalam: s.videoTrafficMalam!,
        video360Siang: s.video360Siang!,
        video360Malam: s.video360Malam!,
        petaCoverage: s.petaCoverage!,
      );

      await _repository.submitKplt(formData);
      state = state.copyWith(status: KpltFormStatus.success);

    } catch (e) {
      state = state.copyWith(status: KpltFormStatus.error, errorMessage: e.toString());
    }
  }
}

// 4. Provider yang akan digunakan oleh UI
// Kita gunakan .family karena kita perlu memberikan ulokId saat provider dibuat
final kpltFormProvider = StateNotifierProvider.autoDispose
    .family<KpltFormNotifier, KpltFormState, String>((ref, ulokId) {
  final repository = ref.watch(kpltRepositoryProvider);
  return KpltFormNotifier(repository, ulokId: ulokId);
});