import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/form_kplt/data/datasources/kplt_draft_manager.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_data.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_state.dart';
import 'package:midi_location/features/form_kplt/domain/repositories/kplt_repository.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';

final kpltDraftManagerProvider = Provider((_) => KpltDraftManager());

class KpltFormNotifier extends StateNotifier<KpltFormState> {
  final KpltRepository _repository;
  final KpltDraftManager _draftManager; 
  final String _ulokId;
  final Ref _ref;

  KpltFormNotifier(this._repository, this._draftManager, this._ref,{required String ulokId})
      : _ulokId = ulokId,
        super(KpltFormState.initial(ulokId: ulokId)) {
    _initialize();
  }

  Future<void> _initialize() async {
    final profile = await _ref.read(userProfileProvider.future);
    final branchId = profile?.branchId;
    final draft = await _draftManager.loadDraft(_ulokId);

    if (draft != null) {
      state = draft.copyWith(branchId: draft.branchId ?? branchId);
    } else {
      state = state.copyWith(branchId: branchId);
    }
  }

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

  Future<bool> saveDraft() async {
    try {
      await _draftManager.saveDraft(state);
      return true; // Kembalikan true jika sukses
    } catch (e) {
      // Handle error jika perlu
      return false; // Kembalikan false jika gagal
    }
  }

  // --- Method utama untuk submit form ---
  Future<bool> submitForm() async {
    debugPrint("--- CHECKING STATE ON SUBMIT ---");
    debugPrint(state.toJson().toString());
    final s = state; 
    if (s.branchId == null || s.karakterLokasi == null || s.sosialEkonomi == null ||
        s.peStatus == null || s.skorFpl == null || s.std == null || s.apc == null ||
        s.spd == null || s.peRab == null || s.pdfFoto == null || s.countingKompetitor == null ||
        s.pdfPembanding == null || s.pdfKks == null || s.excelFpl == null || s.excelPe == null ||
        s.pdfFormUkur == null || s.videoTrafficSiang == null || s.videoTrafficMalam == null ||
        s.video360Siang == null || s.video360Malam == null || s.petaCoverage == null)
    {
      state = state.copyWith(status: KpltFormStatus.error, errorMessage: 'Harap lengkapi semua data.');
      await Future.delayed(const Duration(milliseconds: 100));
      state = state.copyWith(status: KpltFormStatus.initial, errorMessage: null);
      return false;
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
      await _draftManager.deleteDraft(_ulokId);

      final _ = await _ref.refresh(kpltNeedInputProvider.future);
      final _ = await _ref.refresh(kpltInProgressProvider.future);

      state = state.copyWith(status: KpltFormStatus.initial);
      return true;

    } catch (e) {
      state = state.copyWith(status: KpltFormStatus.error, errorMessage: e.toString());
      return false;
    }
  }
}

final kpltFormProvider = StateNotifierProvider.autoDispose
    .family<KpltFormNotifier, KpltFormState, String>((ref, ulokId) {
  final repository = ref.watch(kpltRepositoryProvider);
  final draftManager = ref.watch(kpltDraftManagerProvider);
  return KpltFormNotifier(repository, draftManager, ref, ulokId: ulokId);
});