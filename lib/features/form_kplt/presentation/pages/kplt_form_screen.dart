// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/custom_success_dialog.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_state.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_form_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/core/widgets/file_upload.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/dropdown.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/form_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/text_field.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/ulok_detail_section.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KpltFormPage extends ConsumerStatefulWidget {
  final UsulanLokasi ulok;
  const KpltFormPage({super.key, required this.ulok});
  static const String route = '/kplt/form';

  @override
  ConsumerState<KpltFormPage> createState() => _KpltFormPageState();
}

class _KpltFormPageState extends ConsumerState<KpltFormPage> with SingleTickerProviderStateMixin {
  bool _isDetailExpanded = false;

  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

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

  @override
  void initState() {
    super.initState();
    _expandController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _expandAnimation = CurvedAnimation(parent: _expandController, curve: Curves.easeInOut);
    if (_isDetailExpanded) {
      _expandController.value = 1.0;
    } else {
      _expandController.value = 0.0;
    }
  }

  void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.white,
        color: AppColors.primaryColor,
      ),
    ),
  );
}

  Future<void> _openOrDownloadFile(BuildContext context, String? pathOrUrl, String ulokId) async {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dokumen tidak tersedia.')),
      );
      return;
    }

    String relativePath;
    if (pathOrUrl.startsWith('http')) {
      try {
        final publicIndex = pathOrUrl.indexOf('/public/') + '/public/'.length;
        final bucketAndPath = pathOrUrl.substring(publicIndex);
        relativePath = bucketAndPath.substring(bucketAndPath.indexOf('/') + 1);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format URL lama tidak valid.')));
        return;
      }
    } else {
      relativePath = pathOrUrl;
    }
    final directory = await getApplicationDocumentsDirectory();
    final localFileName = relativePath.split('/').last;
    final localPath = '${directory.path}/$localFileName';
    final localFile = File(localPath);

    if (await localFile.exists()) {
      print("Membuka file dari penyimpanan lokal: $localPath");
      await OpenFilex.open(localPath);
    } else {
      print("File tidak ditemukan lokal, men-download dari: $relativePath");
      _showLoadingDialog(context);

      try {
        final supabase = Supabase.instance.client;
        final fileBytes = await supabase.storage.from('file_storage').download(relativePath);
        Navigator.of(context).pop();

        await localFile.writeAsBytes(fileBytes, flush: true);
        print("File berhasil disimpan di: $localPath");

        await OpenFilex.open(localPath);

      } catch (e) {
        Navigator.of(context).pop();
        print("Gagal mengunduh atau membuka file: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh file: $e')),
        );
      }
    }
  }

  bool _isImageFile(String? filePath) {
    if (filePath == null) return false;
    final lowercasedPath = filePath.toLowerCase();
    return lowercasedPath.endsWith('.png') ||
            lowercasedPath.endsWith('.jpg') ||
            lowercasedPath.endsWith('.jpeg');
  }

  String _getPublicUrl(String filePath) {
    return Supabase.instance.client.storage
        .from('file_storage') 
        .getPublicUrl(filePath);
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
      final selection = controller.selection;
      controller.text = newValue;
      if (selection.start <= newValue.length) {
        controller.selection = selection;
      }
    }
  }

  void _tryComputeSpdAndUpdate() {
    double? parseNum(String s) {
      if (s.trim().isEmpty) return null;
      final normalized = s.replaceAll(',', '').trim();
      return double.tryParse(normalized);
    }

    final stdVal = parseNum(_stdController.text);
    final apcVal = parseNum(_apcController.text);

    if (stdVal == null || apcVal == null) return;
    if (_isUserTypingSpd) return;
    final computed = stdVal * apcVal;

    String toPlainString(double v) {
      if (v.truncateToDouble() == v) {
        return v.truncate().toString();
      } else {
        return v.toString();
      }
    }

    final computedStr = toPlainString(computed);
    try {
      final provider = ref.read(kpltFormProvider(widget.ulok.id).notifier);
      provider.onSpdChanged(computedStr);
    } catch (e) {
      _spdController.text = computedStr;
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
          if (mounted) {
            setState(() {});
          }
        });
      }
    }));
  }

  Widget _smallToggleIcon({required bool up, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              up ? 'Tutup Detail' : 'Buka Detail',
              style: const TextStyle(color: AppColors.primaryColor, fontSize: 12)
              ),
            const SizedBox(width: 8),
            SizedBox(
          height: 40,
          child: Center(
            child: Icon(
                  up ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
              ),
            ),
          ]
        )
      ),
    );
  }

  void _expand() {
    setState(() {
      _isDetailExpanded = true;
      _expandController.forward();
    });
  }

  void _collapse() {
    _expandController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isDetailExpanded = false;
        });
      }
    });
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
            // title card
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.ulok.namaLokasi, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [
                      SvgPicture.asset("assets/icons/time.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                      const SizedBox(width: 4),
                      Text("Approved on $formattedDate", style: const TextStyle(color: Colors.grey, fontSize: 12))
                    ]),
                    const SizedBox(height: 12)
                  ]),
                ),
                // small icon visually attached to bottom center of title card (when collapsed)
                if (!_isDetailExpanded)
                  Positioned(
                    bottom: -20,
                    left: 0,
                    right: 0,
                    top: 60,
                    child: Center(
                      child: _smallToggleIcon(
                        up: false,
                        onTap: _expand,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Expandable area with smooth height animation
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1.0,
              child: Column(
                children: [
                  DetailSectionWidget(
                    title: "Data Usulan Lokasi",
                    iconPath: "assets/icons/location.svg",
                    children: [
                      InfoRowWidget(label: "Alamat", value: fullAddress),
                      InfoRowWidget(label: "LatLong", value: widget.ulok.latLong ?? "-"),
                      const SizedBox(height: 12),
                      InteractiveMapWidget(position: latLng),
                    ],
                  ),

                  const SizedBox(height: 16),

                  DetailSectionWidget(
                    title: "Data Store",
                    iconPath: "assets/icons/data_store.svg",
                    children: [
                      TwoColumnRowWidget(label1: "Format Store", value1: widget.ulok.formatStore ?? '-', label2: "Bentuk Objek", value2: widget.ulok.bentukObjek ?? '-'),
                      TwoColumnRowWidget(label1: "Alas Hak", value1: widget.ulok.alasHak ?? '-', label2: "Jumlah Lantai", value2: widget.ulok.jumlahLantai?.toString() ?? '-'),
                      TwoColumnRowWidget(label1: "Lebar Depan (m)", value1: "${widget.ulok.lebarDepan ?? '-'}", label2: "Panjang (m)", value2: "${widget.ulok.panjang ?? '-'}"),
                      TwoColumnRowWidget(label1: "Luas (m2)", value1: "${widget.ulok.luas ?? '-'}", label2: "Harga Sewa", value2: widget.ulok.hargaSewa != null ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.ulok.hargaSewa) : '-'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  DetailSectionWidget(
                    title: "Data Pemilik",
                    iconPath: "assets/icons/profile.svg",
                    children: [
                      TwoColumnRowWidget(label1: "Nama Pemilik", value1: widget.ulok.namaPemilik ?? '-', label2: "Kontak Pemilik", value2: widget.ulok.kontakPemilik ?? '-'),
                    ],
                  ),

                  // Data Intip: keep file intip
                  if (widget.ulok.approvalIntip != null) ...[
                    const SizedBox(height: 16),
                    DetailSectionWidget(
                      title: "Data Intip",
                      iconPath: "assets/icons/analisis.svg",
                      children: [
                        TwoColumnRowWidget(
                          label1: "Status Intip",
                          value1: widget.ulok.approvalIntip ?? '-',
                          label2: "Tanggal Intip",
                          value2: widget.ulok.tanggalApprovalIntip != null ? DateFormat('dd MMMM yyyy').format(widget.ulok.tanggalApprovalIntip!) : '-',
                        ),

                        if (widget.ulok.fileIntip != null && widget.ulok.fileIntip!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text("File Intip:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 8),
                          _isImageFile(widget.ulok.fileIntip)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _getPublicUrl(widget.ulok.fileIntip!),
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator(backgroundColor: Color(0xFFFFFFFF), color: AppColors.primaryColor));
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Text('Gagal memuat gambar.'));
                                    },
                                  ),
                                )
                              : InkWell(
                                  onTap: () => _openOrDownloadFile(context, widget.ulok.fileIntip, widget.ulok.id),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.picture_as_pdf, color: AppColors.primaryColor),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(widget.ulok.fileIntip!.split('/').last, overflow: TextOverflow.ellipsis)),
                                        const Icon(Icons.open_in_new_rounded, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                        ]
                      ],
                    ),
                  ],

                  if (widget.ulok.formUlok != null && widget.ulok.formUlok!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DetailSectionWidget(
                      title: "Form Ulok",
                      iconPath: "assets/icons/lampiran.svg",
                      children: [
                        InkWell(
                          onTap: () => _openOrDownloadFile(context, widget.ulok.formUlok, widget.ulok.id),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: AppColors.primaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.ulok.formUlok!.split('/').last.split('?').first,
                                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.open_in_new_rounded, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // bottom toggle icon (to collapse)
                  Center(child: _smallToggleIcon(up: true, onTap: _collapse)),

                  const SizedBox(height: 12),
                ],
              ),
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
                    _tryComputeSpdAndUpdate, // <-- after debounce compute attempt
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
                    _tryComputeSpdAndUpdate, // <-- after debounce compute attempt
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
                          final success = await formNotifier.submitForm();
                          if (success && mounted) {
                            _showPopupAndNavigateBack("Data Berhasil Disubmit!", "assets/icons/success.svg");
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