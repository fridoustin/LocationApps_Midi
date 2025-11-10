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
import 'package:midi_location/features/lokasi/domain/entities/form_kplt_state.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_form_provider.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/core/widgets/file_upload.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/detail/info_row.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/dropdown.dart';
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

class _KpltFormPageState extends ConsumerState<KpltFormPage> {
  bool _isDetailExpanded = false;

  final _skorFplController = TextEditingController();
  final _stdController = TextEditingController();
  final _apcController = TextEditingController();
  final _spdController = TextEditingController();
  final _peRabController = TextEditingController();

  // Flags to track if user is currently typing
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

  @override
  void initState() {
    super.initState();
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
      await OpenFilex.open(localPath);
    } else {
      _showLoadingDialog(context);

      try {
        final supabase = Supabase.instance.client;
        final fileBytes = await supabase.storage.from('file_storage').download(relativePath);
        Navigator.of(context).pop();

        await localFile.writeAsBytes(fileBytes, flush: true);
        await OpenFilex.open(localPath);
      } catch (e) {
        Navigator.of(context).pop();
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

    if (stdVal == null || apcVal == null) {
      _spdController.text = '';
      return;
    }
    
    final computed = stdVal * apcVal;

    String toPlainString(double v) {
      if (v.truncateToDouble() == v) {
        return v.truncate().toString();
      } else {
        return v.toString();
      }
    }

    final computedStr = toPlainString(computed);
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
          if (mounted) {
            setState(() {});
          }
        });
      }
    }));
  }

  Widget _buildFileUploadCard(String label, String? fileName, VoidCallback onTap) {
    final hasFile = fileName != null && fileName.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hasFile 
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasFile ? Icons.check_circle : Icons.upload_file,
                  color: hasFile ? AppColors.primaryColor : Colors.grey[600],
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (hasFile) ...[
                      const SizedBox(height: 4),
                      Text(
                        fileName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                hasFile ? Icons.edit : Icons.add_circle_outline,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
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

    final formProvider = kpltFormProvider(widget.ulok.id);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    ref.listen<KpltFormState>(formProvider, (previous, next) {
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
          false, // SPD is always auto-calculated
        );

        _updateControllerIfNeeded(
          _peRabController,
          _formatNumber(next.peRab),
          _isUserTypingPeRab,
        );
      });

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card - Modern Design
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.store,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ulok.namaLokasi,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  "Approved $formattedDate",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isDetailExpanded = !_isDetailExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isDetailExpanded ? 'Sembunyikan Detail' : 'Lihat Detail Usulan',
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _isDetailExpanded 
                                ? Icons.keyboard_arrow_up_rounded 
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expandable Detail Section
            if (_isDetailExpanded) ...[
              const SizedBox(height: 16),

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
                    value1: widget.ulok.lebarDepan != null ? '${widget.ulok.lebarDepan} m' : '-',
                    label2: "Panjang",
                    value2: widget.ulok.panjang != null ? '${widget.ulok.panjang} m' : '-',
                  ),
                  TwoColumnRowWidget(
                    label1: "Luas",
                    value1: widget.ulok.luas != null ? '${widget.ulok.luas} m²' : '-',
                    label2: "Harga Sewa",
                    value2: widget.ulok.hargaSewa != null
                        ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.ulok.hargaSewa)
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
                      value2: widget.ulok.tanggalApprovalIntip != null 
                          ? DateFormat('dd MMMM yyyy').format(widget.ulok.tanggalApprovalIntip!) 
                          : '-',
                    ),
                    if (widget.ulok.fileIntip != null && widget.ulok.fileIntip!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        "File Intip:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _isImageFile(widget.ulok.fileIntip)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _getPublicUrl(widget.ulok.fileIntip!),
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                      color: AppColors.primaryColor,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Text('Gagal memuat gambar.'));
                                },
                              ),
                            )
                          : InkWell(
                              onTap: () => _openOrDownloadFile(context, widget.ulok.fileIntip, widget.ulok.id),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf, color: AppColors.primaryColor),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.ulok.fileIntip!.split('/').last,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.open_in_new_rounded, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                    ],
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
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: AppColors.primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.ulok.formUlok!.split('/').last.split('?').first,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
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
            ],

            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 8),

            // Form Section - Analisa & FPL
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          "assets/icons/analisis.svg",
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Analisa & FPL",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                      _tryComputeSpdAndUpdate,
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
                      _tryComputeSpdAndUpdate,
                    ),
                  ),
                  // SPD Field - Read Only (Auto Calculated)
                  Padding(
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Data PE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          "assets/icons/data_store.svg",
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Data PE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
            ),

            const SizedBox(height: 16),

            // Upload Dokumen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          "assets/icons/lampiran.svg",
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Upload Dokumen",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFileUploadCard(
                    "PDF Foto",
                    formState.pdfFoto?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'pdfFoto'),
                  ),
                  _buildFileUploadCard(
                    "Counting Kompetitor",
                    formState.countingKompetitor?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'countingKompetitor'),
                  ),
                  _buildFileUploadCard(
                    "PDF Pembanding",
                    formState.pdfPembanding?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'pdfPembanding'),
                  ),
                  _buildFileUploadCard(
                    "PDF KKS",
                    formState.pdfKks?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'pdfKks'),
                  ),
                  _buildFileUploadCard(
                    "Excel FPL",
                    formState.excelFpl?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'excelFpl'),
                  ),
                  _buildFileUploadCard(
                    "Excel PE",
                    formState.excelPe?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'excelPe'),
                  ),
                  _buildFileUploadCard(
                    "Video Traffic Siang",
                    formState.videoTrafficSiang?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'videoTrafficSiang'),
                  ),
                  _buildFileUploadCard(
                    "Video Traffic Malam",
                    formState.videoTrafficMalam?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'videoTrafficMalam'),
                  ),
                  _buildFileUploadCard(
                    "Video 360 Siang",
                    formState.video360Siang?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'video360Siang'),
                  ),
                  _buildFileUploadCard(
                    "Video 360 Malam",
                    formState.video360Malam?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'video360Malam'),
                  ),
                  _buildFileUploadCard(
                    "Peta Coverage",
                    formState.petaCoverage?.path.split('/').last,
                    () => pickFile(formNotifier.onFilePicked, 'petaCoverage'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: formState.status == KpltFormStatus.loading
                        ? null
                        : () async {
                            final success = await formNotifier.saveDraft();
                            if (success && mounted) {
                              _showPopupAndNavigateBack(
                                "Draft berhasil disimpan!",
                                "assets/icons/draft.svg",
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Simpan Draft',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: formState.status == KpltFormStatus.loading
                        ? null
                        : () async {
                            final success = await formNotifier.submitForm();
                            if (success && mounted) {
                              _showPopupAndNavigateBack(
                                "Data Berhasil Disubmit!",
                                "assets/icons/success.svg",
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: formState.status == KpltFormStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit KPLT',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}