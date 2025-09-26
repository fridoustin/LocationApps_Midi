// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/custom_success_dialog.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_form_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/core/widgets/file_upload.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/ulok/presentation/widgets/dropdown.dart';
import 'package:midi_location/features/ulok/presentation/widgets/form_card.dart';
import 'package:midi_location/features/ulok/presentation/widgets/helpers/info_row.dart';
import 'package:midi_location/features/ulok/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/ulok/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/ulok/presentation/widgets/text_field.dart';
import 'package:midi_location/features/ulok/presentation/widgets/ulok_detail_section.dart';

class KpltFormPage extends ConsumerStatefulWidget {
  final UsulanLokasi ulok;
  const KpltFormPage({super.key, required this.ulok});
  static const String route = '/kplt/form';

  @override
  ConsumerState<KpltFormPage> createState() => _KpltFormPageState();
}

class _KpltFormPageState extends ConsumerState<KpltFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _skorFplController = TextEditingController();
  final _stdController = TextEditingController();
  final _apcController = TextEditingController();
  final _spdController = TextEditingController();
  final _peRabController = TextEditingController();

  // Flags to track if user is currently typing
  bool _isUserTypingSkorFpl = false;
  bool _isUserTypingStd = false;
  bool _isUserTypingApc = false;
  bool _isUserTypingSpd = false;
  bool _isUserTypingPeRab = false;

  // Debounce timers
  Timer? _skorFplDebounceTimer;
  Timer? _stdDebounceTimer;
  Timer? _apcDebounceTimer;
  Timer? _spdDebounceTimer;
  Timer? _peRabDebounceTimer;

  @override
  void dispose() {
    _skorFplController.dispose();
    _stdController.dispose();
    _apcController.dispose();
    _spdController.dispose();
    _peRabController.dispose();
    
    // Cancel all timers
    _skorFplDebounceTimer?.cancel();
    _stdDebounceTimer?.cancel();
    _apcDebounceTimer?.cancel();
    _spdDebounceTimer?.cancel();
    _peRabDebounceTimer?.cancel();
    
    super.dispose();
  }

  Future<void> _showPopupAndNavigateBack(String message, String iconPath) async {
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

  String _formatNumber(num? number) {
    if (number == null) return '';
    if (number.truncateToDouble() == number) return number.truncate().toString();
    return number.toString();
  }

  void _updateControllerIfNeeded(
    TextEditingController controller,
    String newValue,
    bool isUserTyping,
  ) {
    if (!isUserTyping && controller.text != newValue) {
      // Save cursor position
      final selection = controller.selection;
      controller.text = newValue;
      
      // Restore cursor position if it's still valid
      if (selection.start <= newValue.length) {
        controller.selection = selection;
      }
    }
  }

  void _handleTextFieldChange(
    String value,
    Function(String) onChanged,
    Function() setUserTypingTrue,
    Timer? debounceTimer,
    Function(Timer?) setDebounceTimer,
  ) {
    setUserTypingTrue();
    
    // Cancel previous timer
    debounceTimer?.cancel();
    
    // Set new timer
    setDebounceTimer(Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        onChanged(value);
        // Reset typing flag after a short delay
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              // Reset the corresponding typing flag
            });
          }
        });
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("dd MMMM yyyy").format(widget.ulok.tanggal);
    final latLngParts = widget.ulok.latLong?.split(',') ?? ['0', '0'];
    final latLng = LatLng(
        double.tryParse(latLngParts[0]) ?? 0.0,
        double.tryParse(latLngParts[1]) ?? 0.0);
    final fullAddress = [
      widget.ulok.alamat,
      widget.ulok.desaKelurahan,
      widget.ulok.kecamatan.isNotEmpty ? 'Kec. ${widget.ulok.kecamatan}' : '',
      widget.ulok.kabupaten,
      widget.ulok.provinsi,
    ].where((e) => e.isNotEmpty).join(', ');

    // Mengakses provider form
    final formProvider = kpltFormProvider(widget.ulok.id);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    // Listener untuk menampilkan Snackbar dan navigasi
    ref.listen<KpltFormState>(formProvider, (previous, next) {
      // Update controllers only when user is not typing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _updateControllerIfNeeded(
          _skorFplController,
          _formatNumber(next.skorFpl),
          _isUserTypingSkorFpl,
        );

        _updateControllerIfNeeded(
          _stdController,
          _formatNumber(next.std),
          _isUserTypingStd,
        );

        _updateControllerIfNeeded(
          _apcController,
          _formatNumber(next.apc),
          _isUserTypingApc,
        );

        _updateControllerIfNeeded(
          _spdController,
          _formatNumber(next.spd),
          _isUserTypingSpd,
        );

        _updateControllerIfNeeded(
          _peRabController,
          _formatNumber(next.peRab),
          _isUserTypingPeRab,
        );
      });

      // Handle status aksi
      if (previous?.status != next.status) {
        if (next.status == KpltFormStatus.error && next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
          );
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          ref.read(formProvider.notifier).state = next.copyWith(status: KpltFormStatus.initial, errorMessage: null);
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Form Input KPLT',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.ulok.namaLokasi,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [
                      SvgPicture.asset("assets/icons/time.svg",
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                              Colors.grey, BlendMode.srcIn)),
                      const SizedBox(width: 4),
                      Text("Approved on $formattedDate",
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12))
                    ])
                  ]),
            ),
            const SizedBox(height: 16),
            DetailSectionWidget(
                title: "Data Usulan Lokasi",
                iconPath: "assets/icons/location.svg",
                children: [
                  InfoRowWidget(label: "Alamat", value: fullAddress),
                  InfoRowWidget(
                      label: "LatLong", value: widget.ulok.latLong ?? "-"),
                  const SizedBox(height: 12),
                  InteractiveMapWidget(position: latLng)
                ]),
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
                    value2: widget.ulok.jumlahLantai?.toString() ?? '-'
                  ),
                  TwoColumnRowWidget(
                    label1: "Lebar Depan (m)",
                    value1: "${widget.ulok.lebarDepan ?? '-'}",
                    label2: "Panjang (m)",
                    value2: "${widget.ulok.panjang ?? '-'}"
                  ),
                  TwoColumnRowWidget(
                    label1: "Luas (m2)",
                    value1: "${widget.ulok.luas ?? '-'}",
                    label2: "Harga Sewa",
                    value2: widget.ulok.hargaSewa != null
                        ? NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(widget.ulok.hargaSewa)
                        : '-'
                  ),
                ]),
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
            const Divider(thickness: 1, height: 32),
            FormCardSection( 
              title: "Analisa & FPL",
              iconAsset: "assets/icons/analisis.svg",
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
                  ),
                ),
                FormTextField(
                  controller: _spdController,
                  label: "SPD",
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _handleTextFieldChange(
                    value,
                    formNotifier.onSpdChanged,
                    () => _isUserTypingSpd = true,
                    _spdDebounceTimer,
                    (timer) => _spdDebounceTimer = timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormCardSection(
              title: "Data PE",
              iconAsset: "assets/icons/data_store.svg",
              children: [
                PopupButtonForm(
                  label: "PE Status",
                  optionsProvider: dropdownOptionsProvider('PE_Status'), 
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
            ),
            const SizedBox(height: 16),
            FormCardSection(
                title: "Upload Dokumen",
                iconAsset: "assets/icons/lampiran.svg", 
                children: [
                  FileUploadWidget(
                      label: "PDF Foto",
                      fileName: formState.pdfFoto?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'pdfFoto')),
                  FileUploadWidget(
                      label: "Counting Kompetitor",
                      fileName: formState.countingKompetitor?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'countingKompetitor')),
                  FileUploadWidget(
                      label: "PDF Pembanding",
                      fileName: formState.pdfPembanding?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'pdfPembanding')),
                  FileUploadWidget(
                      label: "PDF KKS",
                      fileName: formState.pdfKks?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'pdfKks')),
                  FileUploadWidget(
                      label: "Excel FPL",
                      fileName: formState.excelFpl?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'excelFpl')),
                  FileUploadWidget(
                      label: "Excel PE",
                      fileName: formState.excelPe?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'excelPe')),
                  FileUploadWidget(
                      label: "PDF Form Ukur",
                      fileName: formState.pdfFormUkur?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'pdfFormUkur')),
                  FileUploadWidget(
                      label: "Video Traffic Siang",
                      fileName: formState.videoTrafficSiang?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'videoTrafficSiang')),
                  FileUploadWidget(
                      label: "Video Traffic Malam",
                      fileName: formState.videoTrafficMalam?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'videoTrafficMalam')),
                  FileUploadWidget(
                      label: "Video 360 Siang",
                      fileName: formState.video360Siang?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'video360Siang')),
                  FileUploadWidget(
                      label: "Video 360 Malam",
                      fileName: formState.video360Malam?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'video360Malam')),
                  FileUploadWidget(
                      label: "Peta Coverage",
                      fileName: formState.petaCoverage?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'petaCoverage'))
                ]),
            const SizedBox(height: 30),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child :Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: formState.status == KpltFormStatus.loading ? null : () async {
                          final success = await formNotifier.saveDraft();
                          if (success && mounted) {
                            _showPopupAndNavigateBack("Draft berhasil disimpan!", "assets/icons/draft.svg");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cardColor,
                          foregroundColor: AppColors.primaryColor,
                          side: const BorderSide(color: AppColors.primaryColor),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Simpan Draft'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: formState.status == KpltFormStatus.loading ? null : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final success = await formNotifier.submitForm();
                            if (success && mounted) {
                              _showPopupAndNavigateBack("Data Berhasil Disubmit!", "assets/icons/success.svg");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: formState.status == KpltFormStatus.loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Simpan Data KPLT'),
                      ),
                    ),
                  ],
                )
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}