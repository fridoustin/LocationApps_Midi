// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/file_service.dart';
import 'package:midi_location/core/utils/date_formatter.dart';
import 'package:midi_location/core/widgets/custom_success_dialog.dart';
import 'package:midi_location/core/widgets/confirmation_dialog.dart'; // Import Widget Universal
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/domain/entities/form_kplt_state.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_form_provider.dart';
import 'package:midi_location/core/widgets/file_upload.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/detail_section_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/file_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/dropdown.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/form/file_upload_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/form/form_action_button.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/form/form_header_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/form/form_section_container.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/form/form_section_header.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/form/text_field_controller.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/text_field.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/ulok_detail_section.dart';

class KpltFormPage extends ConsumerStatefulWidget {
  final UsulanLokasi ulok;
  const KpltFormPage({super.key, required this.ulok});
  static const String route = '/kplt/form';

  @override
  ConsumerState<KpltFormPage> createState() => _KpltFormPageState();
}

class _KpltFormPageState extends ConsumerState<KpltFormPage>
    with TextFieldControllerMixin {
  bool _isDetailExpanded = false;

  // Text Controllers
  final _skorFplController = TextEditingController();
  final _stdController = TextEditingController();
  final _apcController = TextEditingController();
  final _spdController = TextEditingController();
  final _peRabController = TextEditingController();

  // Typing flags
  bool _isUserTypingSkorFpl = false;
  bool _isUserTypingStd = false;
  bool _isUserTypingApc = false;
  bool _isUserTypingPeRab = false;

  // Debounce timers
  Timer? _skorFplDebounceTimer;
  Timer? _stdDebounceTimer;
  Timer? _apcDebounceTimer;
  Timer? _peRabDebounceTimer;

  @override
  void dispose() {
    _skorFplController.dispose();
    _stdController.dispose();
    _apcController.dispose();
    _spdController.dispose();
    _peRabController.dispose();

    _skorFplDebounceTimer?.cancel();
    _stdDebounceTimer?.cancel();
    _apcDebounceTimer?.cancel();
    _peRabDebounceTimer?.cancel();

    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final confirm = await showConfirmationDialog(
      context,
      title: "Batalkan Pengisian?",
      content: "Data KPLT yang belum disimpan akan hilang. Yakin ingin keluar?",
      confirmText: "Ya, Keluar",
      icon: Icons.warning_amber_rounded,
      confirmColor: Colors.red,
    );
    return confirm ?? false;
  }

  Future<void> _showPopupAndNavigateBack(
      String message, String iconPath) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          CustomSuccessDialog(title: message, iconPath: iconPath),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context).pop();
    if (mounted) Navigator.of(context).pop();
  }

  void _computeSpdAndUpdate() {
    double? parseNum(String s) {
      if (s.trim().isEmpty) return null;
      final normalized = s.replaceAll(',', '').trim();
      return double.tryParse(normalized);
    }

    final stdVal = parseNum(_stdController.text);
    final apcVal = parseNum(_apcController.text);

    if (stdVal == null || apcVal == null) {
      _spdController.text = '';
      return;
    }

    final computed = stdVal * apcVal;
    final computedStr = formatNumber(computed);
    _spdController.text = computedStr;

    try {
      final provider = ref.read(kpltFormProvider(widget.ulok.id).notifier);
      provider.onSpdChanged(computedStr);
    } catch (e) {
      // Already set in controller
    }
  }

  void _handleTextFieldChange(
    String value,
    Function(String) onChanged,
    Function() setUserTypingTrue,
    Timer? debounceTimer,
    Function(Timer?) setDebounceTimer, [
    VoidCallback? afterDebounce,
  ]) {
    setUserTypingTrue();
    debounceTimer?.cancel();

    setDebounceTimer(Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        onChanged(value);
        if (afterDebounce != null) {
          afterDebounce();
        }
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() {});
        });
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat("dd MMMM yyyy").format(widget.ulok.approvedAt!);
    final latLngParts = widget.ulok.latLong?.split(',') ?? ['0', '0'];
    final latLng = LatLng(
      double.tryParse(latLngParts[0]) ?? 0.0,
      double.tryParse(latLngParts[1]) ?? 0.0,
    );
    final fullAddress = [
      widget.ulok.alamat,
      widget.ulok.desaKelurahan,
      widget.ulok.kecamatan.isNotEmpty ? 'Kec. ${widget.ulok.kecamatan}' : '',
      widget.ulok.kabupaten,
      widget.ulok.provinsi,
    ].where((e) => e.isNotEmpty).join(', ');

    final formProvider = kpltFormProvider(widget.ulok.id);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    ref.listen<KpltFormState>(formProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        updateControllerIfNeeded(
          _skorFplController,
          formatNumber(next.skorFpl),
          _isUserTypingSkorFpl,
        );

        updateControllerIfNeeded(
          _stdController,
          formatNumber(next.std),
          _isUserTypingStd,
        );

        updateControllerIfNeeded(
          _apcController,
          formatNumber(next.apc),
          _isUserTypingApc,
        );

        updateControllerIfNeeded(
          _spdController,
          formatNumber(next.spd),
          false,
        );

        updateControllerIfNeeded(
          _peRabController,
          formatNumber(next.peRab),
          _isUserTypingPeRab,
        );
      });

      if (previous?.status != next.status) {
        if (next.status == KpltFormStatus.error && next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(next.errorMessage!),
                backgroundColor: Colors.red),
          );
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          ref.read(formProvider.notifier).state =
              next.copyWith(status: KpltFormStatus.initial, errorMessage: null);
        }
      }
    });

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomTopBar.general(
          title: 'Form Input KPLT',
          showNotificationButton: false,
          leadingWidget: IconButton(
            icon: SvgPicture.asset(
              "assets/icons/left_arrow.svg",
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            onPressed: () async {
              if (await _onWillPop()) {
                if (mounted) Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Card
              FormHeaderCard(
                title: widget.ulok.namaLokasi,
                subtitle: "Approved $formattedDate",
                icon: Icons.store,
                isExpandable: true,
                isExpanded: _isDetailExpanded,
                onToggleExpanded: () {
                  setState(() {
                    _isDetailExpanded = !_isDetailExpanded;
                  });
                },
              ),

              // Expandable Detail Section
              if (_isDetailExpanded) ...[
                const SizedBox(height: 16),
                _buildUlokDetailSection(fullAddress, latLng),
              ],

              const SizedBox(height: 8),
              const Divider(thickness: 1),
              const SizedBox(height: 8),

              // Analisa & FPL Section
              FormSectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormSectionHeader(
                      title: "Analisa & FPL",
                      iconPath: "assets/icons/analisis.svg",
                    ),
                    const SizedBox(height: 20),
                    _buildAnalisaFplFields(formState, formNotifier),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Data PE Section
              FormSectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormSectionHeader(
                      title: "Data PE",
                      iconPath: "assets/icons/data_store.svg",
                    ),
                    const SizedBox(height: 20),
                    _buildDataPeFields(formState, formNotifier),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Upload Dokumen Section
              FormSectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormSectionHeader(
                      title: "Upload Dokumen",
                      iconPath: "assets/icons/lampiran.svg",
                    ),
                    const SizedBox(height: 16),
                    _buildFileUploadSection(formState, formNotifier),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              FormActionButtons(
                isLoading: formState.status == KpltFormStatus.loading,
                onDraftPressed: () async {
                  final confirm = await showConfirmationDialog(
                    context,
                    title: "Simpan Draft KPLT?",
                    content: "Data akan disimpan sementara. Anda bisa melanjutkannya nanti.",
                    confirmText: "Simpan Draft",
                    icon: Icons.save_as_outlined,
                    confirmColor: AppColors.primaryColor,
                  );

                  if (confirm == true) {
                    final success = await formNotifier.saveDraft();
                    if (success && mounted) {
                      _showPopupAndNavigateBack(
                        "Draft berhasil disimpan!",
                        "assets/icons/draft.svg",
                      );
                    }
                  }
                },
                onSubmitPressed: () async {
                  final confirm = await showConfirmationDialog(
                    context,
                    title: "Submit KPLT?",
                    content: "Pastikan semua data sudah terisi lengkap dan benar sebelum submit.",
                    confirmText: "Ya, Submit",
                    icon: Icons.check_circle_outline,
                    confirmColor: AppColors.successColor,
                  );

                  if (confirm == true) {
                    final success = await formNotifier.submitForm();
                    if (success && mounted) {
                      _showPopupAndNavigateBack(
                        "Data Berhasil Disubmit!",
                        "assets/icons/success.svg",
                      );
                    }
                  }
                },
                submitLabel: 'Submit KPLT',
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUlokDetailSection(String fullAddress, LatLng latLng) {
    return Column(
      children: [
        DetailSectionWidget(
          title: "Data Usulan Lokasi",
          iconPath: "assets/icons/location.svg",
          children: [
            InfoRow(label: "Alamat", value: fullAddress),
            InfoRow(label: "LatLong", value: widget.ulok.latLong ?? "-"),
            const SizedBox(height: 12),
            InteractiveMapWidget(position: latLng),
          ],
        ),
        const SizedBox(height: 16),
        DetailSectionWidget(
          title: "Data Store",
          iconPath: "assets/icons/data_store.svg",
          children: [
            TwoColumnRowWidget(
              label1: "Format Store",
              value1: widget.ulok.formatStore ?? '-',
              label2: "Bentuk Objek",
              value2: widget.ulok.bentukObjek ?? '-',
            ),
            TwoColumnRowWidget(
              label1: "Alas Hak",
              value1: widget.ulok.alasHak ?? '-',
              label2: "Jumlah Lantai",
              value2: widget.ulok.jumlahLantai?.toString() ?? '-',
            ),
            TwoColumnRowWidget(
              label1: "Lebar Depan",
              value1: widget.ulok.lebarDepan != null
                  ? '${widget.ulok.lebarDepan} m'
                  : '-',
              label2: "Panjang",
              value2:
                  widget.ulok.panjang != null ? '${widget.ulok.panjang} m' : '-',
            ),
            TwoColumnRowWidget(
              label1: "Luas",
              value1: widget.ulok.luas != null ? '${widget.ulok.luas} m²' : '-',
              label2: "Harga Sewa",
              value2: widget.ulok.hargaSewa != null
                  ? NumberFormat.currency(
                          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                      .format(widget.ulok.hargaSewa)
                  : '-',
            ),
          ],
        ),
        const SizedBox(height: 16),
        DetailSectionWidget(
          title: "Data Pemilik",
          iconPath: "assets/icons/profile.svg",
          children: [
            TwoColumnRowWidget(
              label1: "Nama Pemilik",
              value1: widget.ulok.namaPemilik ?? '-',
              label2: "Kontak Pemilik",
              value2: widget.ulok.kontakPemilik ?? '-',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.ulok.formUlok != null && widget.ulok.formUlok!.isNotEmpty) ... [
          DetailSectionCard(
            title: "Form Ulok",
            icon: Icons.description,
            children: [
              FileRow(
                    label: "Form Ulok",
                    filePath: widget.ulok.formUlok!,
                    onTap: () => FileService.openOrDownloadFile(
                      context,
                      widget.ulok.formUlok,
                    ),
                  ),
            ],
          )
        ],
        const SizedBox(height: 16),

        DetailSectionCard(
          title: 'Informasi Tambahan',
          icon: Icons.info_outline,
          children: [
            TwoColumnRowWidget(
                label1: "Tanggal Ulok Dibuat",
                value1: DateFormatter.formatDate(widget.ulok.createdAt),
                label2: "Dibuat oleh",
                value2: widget.ulok.createdBy!,
              ),
            if (widget.ulok.approvedAt != null && widget.ulok.status == 'OK') ...[
              const SizedBox(height: 12),
              TwoColumnRowWidget(
                label1: "Tanggal Ulok Disetujui",
                value1: DateFormatter.formatDate(widget.ulok.approvedAt!),
                label2: "Disetujui oleh",
                value2: widget.ulok.approvedBy!,
              ),
            ],
            if (widget.ulok.updatedAt != null && widget.ulok.status == 'NOK') ...[
              const SizedBox(height: 12),
              TwoColumnRowWidget(
                label1: "Tanggal Ulok Ditolak",
                value1: DateFormatter.formatDate(widget.ulok.updatedAt!),
                label2: "Ditolak oleh",
                value2: widget.ulok.updatedBy!,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAnalisaFplFields(
      KpltFormState formState, dynamic formNotifier) {
    return Column(
      children: [
        PopupButtonForm(
          label: "Karakter Lokasi",
          optionsProvider: dropdownOptionsProvider('karakter'),
          selectedValue: formState.karakterLokasi,
          onSelected: (value) => formNotifier.onKarakterLokasiChanged(value!),
        ),
        PopupButtonForm(
          label: "Sosial Ekonomi",
          optionsProvider: dropdownOptionsProvider('social'),
          selectedValue: formState.sosialEkonomi,
          onSelected: (value) => formNotifier.onSosialEkonomiChanged(value!),
        ),
        FormTextField(
          controller: _skorFplController,
          label: "Skor FPL",
          keyboardType: TextInputType.number,
          onChanged: (value) => _handleTextFieldChange(
            value,
            formNotifier.onSkorFplChanged,
            () => _isUserTypingSkorFpl = true,
            _skorFplDebounceTimer,
            (timer) => _skorFplDebounceTimer = timer,
          ),
        ),
        FormTextField(
          controller: _stdController,
          label: "STD",
          keyboardType: TextInputType.number,
          onChanged: (value) => _handleTextFieldChange(
            value,
            formNotifier.onStdChanged,
            () => _isUserTypingStd = true,
            _stdDebounceTimer,
            (timer) => _stdDebounceTimer = timer,
            _computeSpdAndUpdate,
          ),
        ),
        FormTextField(
          controller: _apcController,
          label: "APC",
          keyboardType: TextInputType.number,
          onChanged: (value) => _handleTextFieldChange(
            value,
            formNotifier.onApcChanged,
            () => _isUserTypingApc = true,
            _apcDebounceTimer,
            (timer) => _apcDebounceTimer = timer,
            _computeSpdAndUpdate,
          ),
        ),
        _buildSpdReadOnlyField(),
      ],
    );
  }

  Widget _buildSpdReadOnlyField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: AppColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: "SPD"),
                TextSpan(
                  text: " *",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AbsorbPointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _spdController.text.isEmpty
                          ? 'Otomatis dihitung dari STD × APC'
                          : _spdController.text,
                      style: TextStyle(
                        color: _spdController.text.isEmpty
                            ? AppColors.black.withOpacity(0.5)
                            : AppColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.calculate,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPeFields(KpltFormState formState, dynamic formNotifier) {
    return Column(
      children: [
        PopupButtonForm(
          label: "PE Status",
          optionsProvider: dropdownOptionsProvider('pe_status'),
          selectedValue: formState.peStatus,
          onSelected: (value) => formNotifier.onPeStatusChanged(value!),
        ),
        FormTextField(
          controller: _peRabController,
          label: "PE RAB",
          keyboardType: TextInputType.number,
          onChanged: (value) => _handleTextFieldChange(
            value,
            formNotifier.onPeRabChanged,
            () => _isUserTypingPeRab = true,
            _peRabDebounceTimer,
            (timer) => _peRabDebounceTimer = timer,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection(
      KpltFormState formState, dynamic formNotifier) {
    return Column(
      children: [
        FileUploadCard(
          label: "PDF Foto",
          fileName: formState.pdfFoto?.path.split('/').last,
          onTap: () => pickFile(formNotifier.onFilePicked, 'pdfFoto'),
        ),
        FileUploadCard(
          label: "Counting Kompetitor",
          fileName: formState.countingKompetitor?.path.split('/').last,
          onTap: () =>
              pickFile(formNotifier.onFilePicked, 'countingKompetitor'),
        ),
        FileUploadCard(
          label: "PDF Pembanding",
          fileName: formState.pdfPembanding?.path.split('/').last,
          onTap: () => pickFile(formNotifier.onFilePicked, 'pdfPembanding'),
        ),
        FileUploadCard(
          label: "PDF KKS",
          fileName: formState.pdfKks?.path.split('/').last,
          onTap: () => pickFile(formNotifier.onFilePicked, 'pdfKks'),
        ),
        FileUploadCard(
          label: "Excel FPL",
          fileName: formState.excelFpl?.path.split('/').last,
          onTap: () => pickFile(formNotifier.onFilePicked, 'excelFpl'),
        ),
        FileUploadCard(
          label: "Excel PE",
          fileName: formState.excelPe?.path.split('/').last,
          onTap: () => pickFile(formNotifier.onFilePicked, 'excelPe'),
        ),
        FileUploadCard(
          label: "Video Traffic Siang",
          fileName: formState.videoTrafficSiang?.path.split('/').last,
          onTap: () =>
              pickFile(formNotifier.onFilePicked, 'videoTrafficSiang'),
        ),
        FileUploadCard(
          label: "Video Traffic Malam",
          fileName: formState.videoTrafficMalam?.path.split('/').last,
          onTap: () =>
              pickFile(formNotifier.onFilePicked, 'videoTrafficMalam'),
        ),
        FileUploadCard(
          label: "Video 360 Siang",
          fileName: formState.video360Siang?.path.split('/').last,
          onTap: () => pickFile(formNotifier.onFilePicked, 'video360Siang'),
        ),
        FileUploadCard(
          label: "Video 360 Malam",
          fileName: formState.video360Malam?.path.split('/').last,
          onTap: () => pickFile(formNotifier.onFilePicked, 'video360Malam'),
        ),
        FileUploadCard(
          label: "Peta Coverage",
          fileName: formState.petaCoverage?.path.split('/').last,
          onTap: () => pickFile(formNotifier.onFilePicked, 'petaCoverage'),
        ),
      ],
    );
  }
}