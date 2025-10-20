// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/custom_success_dialog.dart';
import 'package:midi_location/core/widgets/file_upload.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt.dart';
import 'package:midi_location/features/form_kplt/domain/entities/form_kplt_state.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_form_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/ulok/presentation/widgets/dropdown.dart';
import 'package:midi_location/features/ulok/presentation/widgets/form_card.dart';
import 'package:midi_location/features/ulok/presentation/widgets/map_picker.dart';
import 'package:midi_location/features/ulok/presentation/widgets/text_field.dart';
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';
import 'package:midi_location/features/wilayah/presentation/providers/wilayah_provider.dart';
import 'package:midi_location/features/wilayah/presentation/widgets/wilayah_dropdown.dart';

class KpltEditPage extends ConsumerStatefulWidget {
  final FormKPLT kplt;
  const KpltEditPage({super.key, required this.kplt});

  @override
  ConsumerState<KpltEditPage> createState() => _KpltEditPageState();
}

class _KpltEditPageState extends ConsumerState<KpltEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final MapController _mapController;
  
  final _namaLokasiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _desaController = TextEditingController();
  final _kabupatenController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _formatStoreController = TextEditingController();
  final _bentukObjekController = TextEditingController();
  final _alasHakController = TextEditingController();
  final _jumlahLantaiController = TextEditingController();
  final _lebarDepanController = TextEditingController();
  final _panjangController = TextEditingController();
  final _luasController = TextEditingController();
  final _hargaSewaController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _kontakPemilikController = TextEditingController();
  final _skorFplController = TextEditingController();
  final _stdController = TextEditingController();
  final _apcController = TextEditingController();
  final _spdController = TextEditingController();
  final _peRabController = TextEditingController();
  bool _isUserTypingJumlahLantai = false, _isUserTypingLebarDepan = false, _isUserTypingPanjang = false;
  bool _isUserTypingLuas = false, _isUserTypingHargaSewa = false;
  bool _isUserTypingSkorFpl = false, _isUserTypingStd = false, _isUserTypingApc = false;
  bool _isUserTypingSpd = false, _isUserTypingPeRab = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); 
    _namaLokasiController.text = widget.kplt.namaLokasi;
    _alamatController.text = widget.kplt.alamat;
    _kecamatanController.text = widget.kplt.kecamatan;
    _desaController.text = widget.kplt.desaKelurahan;
    _kabupatenController.text = widget.kplt.kabupaten;
    _provinsiController.text = widget.kplt.provinsi;
    _formatStoreController.text = widget.kplt.formatStore ?? '';
    _bentukObjekController.text = widget.kplt.bentukObjek ?? '';
    _alasHakController.text = widget.kplt.alasHak ?? '';
    _jumlahLantaiController.text = widget.kplt.jumlahLantai?.toString() ?? '';
    _lebarDepanController.text = widget.kplt.lebarDepan?.toString() ?? '';
    _panjangController.text = widget.kplt.panjang?.toString() ?? '';
    _luasController.text = widget.kplt.luas?.toString() ?? '';
    _hargaSewaController.text = widget.kplt.hargaSewa?.toInt().toString() ?? '';
    _namaPemilikController.text = widget.kplt.namaPemilik ?? '';
    _kontakPemilikController.text = widget.kplt.kontakPemilik ?? '';
    _skorFplController.text = widget.kplt.skorFpl?.toString() ?? '';
    _stdController.text = widget.kplt.std?.toString() ?? '';
    _apcController.text = widget.kplt.apc?.toString() ?? '';
    _spdController.text = widget.kplt.spd?.toString() ?? '';
    _peRabController.text = widget.kplt.peRab?.toInt().toString() ?? '';
  }

  @override
  void dispose() {
    _mapController.dispose();
    _namaLokasiController.dispose();
    _alamatController.dispose();
    _alasHakController.dispose();
    _jumlahLantaiController.dispose();
    _lebarDepanController.dispose();
    _panjangController.dispose();
    _luasController.dispose();
    _hargaSewaController.dispose();
    _namaPemilikController.dispose();
    _kontakPemilikController.dispose();
    _skorFplController.dispose();
    _stdController.dispose();
    _apcController.dispose();
    _spdController.dispose();
    _peRabController.dispose();
    super.dispose();
  }

  String _formatNumber(num? number) {
    if (number == null) return '';
    if (number.truncateToDouble() == number) return number.truncate().toString();
    return number.toString();
  }
  
  void _updateControllerIfNeeded(TextEditingController controller, String newValue, bool isUserTyping) {
    if (!isUserTyping && controller.text != newValue) {
        controller.text = newValue;
    }
  }

  Future<void> _openMapDialog(KpltFormNotifier notifier, LatLng? currentLatLng) async { 
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Izin lokasi ditolak")));
      }
      return;
    }

    final LatLng? selectedLatLng = await showDialog<LatLng>(
      context: context,
      builder: (context) => MapPickerDialog(initialPoint: currentLatLng),
    );
    if (selectedLatLng != null) {
      notifier.onLatLngChanged(selectedLatLng); 
    }
  }

  Widget _buildMapPreview(KpltFormState formState) { // aman
    final latLngParts = widget.kplt.latLong?.split(',') ?? ['0', '0'];
    final initialLatLng = LatLng(double.tryParse(latLngParts[0]) ?? 0.0, double.tryParse(latLngParts[1]) ?? 0.0);
    final displayLatLng = formState.ulokId == widget.kplt.ulokId ? initialLatLng : initialLatLng; 
    // ignore: unnecessary_null_comparison
    if (displayLatLng == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        height: 250,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: formState.latLng!,
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.midi.location',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: formState.latLng!,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primaryColor,
                      size: 40,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoomIn',
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.white,
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoomOut',
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.white,
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPopupAndNavigateBack(String message, String iconPath) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomSuccessDialog(title: message, iconPath: iconPath),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context).pop(); 
    if (mounted) Navigator.of(context).pop(); 
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = kpltEditFormProvider(widget.kplt);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    ref.listen<KpltFormState>(formProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_namaLokasiController.text != next.namaLokasi) _namaLokasiController.text = next.namaLokasi ?? '';
        if (_alamatController.text != next.alamat) _alamatController.text = next.alamat ?? '';
        if (_alasHakController.text != next.alasHak) _alasHakController.text = next.alasHak ?? '';
        if (_namaPemilikController.text != next.namaPemilik) _namaPemilikController.text = next.namaPemilik ?? '';
        if (_kontakPemilikController.text != next.kontakPemilik) _kontakPemilikController.text = next.kontakPemilik ?? '';
        
        _updateControllerIfNeeded(_jumlahLantaiController, _formatNumber(next.jumlahLantai), _isUserTypingJumlahLantai);
        _updateControllerIfNeeded(_lebarDepanController, _formatNumber(next.lebarDepan), _isUserTypingLebarDepan);
        _updateControllerIfNeeded(_panjangController, _formatNumber(next.panjang), _isUserTypingPanjang);
        _updateControllerIfNeeded(_luasController, _formatNumber(next.luas), _isUserTypingLuas);
        _updateControllerIfNeeded(_hargaSewaController, _formatNumber(next.hargaSewa), _isUserTypingHargaSewa);
        _updateControllerIfNeeded(_skorFplController, _formatNumber(next.skorFpl), _isUserTypingSkorFpl);
        _updateControllerIfNeeded(_stdController, _formatNumber(next.std), _isUserTypingStd);
        _updateControllerIfNeeded(_apcController, _formatNumber(next.apc), _isUserTypingApc);
        _updateControllerIfNeeded(_spdController, _formatNumber(next.spd), _isUserTypingSpd);
        _updateControllerIfNeeded(_peRabController, _formatNumber(next.peRab), _isUserTypingPeRab);

        if (previous?.status != next.status && next.status == KpltFormStatus.error && next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Edit KPLT',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset("assets/icons/left_arrow.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form( // Anda sudah punya widget Form ini
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              FormCardSection(
                title: "Data Usulan Lokasi",
                iconAsset: "assets/icons/location.svg",
                children: [
                  FormTextField(
                    controller: _namaLokasiController, 
                    label: "Nama Lokasi",
                    onChanged: formNotifier.onNamaLokasiChanged,
                  ),
                  SearchableDropdown(
                      label: "Provinsi *",
                      itemsProvider: provincesProvider,
                      selectedValue: formState.provinsi != null ? WilayahEntity(id: '', name: formState.provinsi!) : null,
                      onChanged: formNotifier.onProvinceSelected,
                    ),
                    SearchableDropdown(
                      label: "Kabupaten/Kota *",
                      isEnabled: formState.provinsi != null,
                      itemsProvider: regenciesProvider,
                      selectedValue: formState.kabupaten != null ? WilayahEntity(id: '', name: formState.kabupaten!) : null,
                      onChanged: formNotifier.onRegencySelected,
                    ),
                    SearchableDropdown(
                      label: "Kecamatan *",
                      isEnabled: formState.kabupaten != null,
                      itemsProvider: districtsProvider,
                      selectedValue: formState.kecamatan != null ? WilayahEntity(id: '', name: formState.kecamatan!) : null,
                      onChanged: formNotifier.onDistrictSelected,
                    ),
                    SearchableDropdown(
                      label: "Desa/Kelurahan *",
                      isEnabled: formState.kecamatan != null,
                      itemsProvider: villagesProvider,
                      selectedValue: formState.desaKelurahan != null ? WilayahEntity(id: '', name: formState.desaKelurahan!) : null,
                      onChanged: formNotifier.onVillageSelected,
                    ),
                  FormTextField(
                    controller: _alamatController, 
                    label: "Alamat",
                    onChanged: formNotifier.onAlamatChanged,
                    ),
                  FormTextField(
                      controller: TextEditingController(text: formState.latLng != null ? '${formState.latLng!.latitude.toStringAsFixed(6)}, ${formState.latLng!.longitude.toStringAsFixed(6)}' : ''),
                      label: 'Latlong',
                      readOnly: true,
                      onTap: () => _openMapDialog(formNotifier, formState.latLng),
                    ),
                    _buildMapPreview(formState),
                ],
              ),
              const SizedBox(height: 16),
              FormCardSection(
                title: "Data Store",
                iconAsset: "assets/icons/data_store.svg",
                children: [
                  PopupButtonForm(
                    label: 'Format Store', 
                    optionsProvider: dropdownOptionsProvider('format_store'), 
                    selectedValue: formState.formatStore, 
                    onSelected: (v) => formNotifier.onFormatStoreChanged(v!)
                  ),
                  PopupButtonForm(
                    label: 'Bentuk Objek', 
                    optionsProvider: dropdownOptionsProvider('bentuk_objek'), 
                    selectedValue: formState.bentukObjek, 
                    onSelected: (v) => formNotifier.onBentukObjekChanged(v!)
                  ),
                  FormTextField(
                    controller: _alasHakController, 
                    label: "Alas Hak",
                    onChanged: formNotifier.onAlasHakChanged
                  ),
                  FormTextField(
                    controller: _jumlahLantaiController, 
                    label: "Jumlah Lantai", 
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _isUserTypingJumlahLantai = true;
                      formNotifier.onJumlahLantaiChanged(value);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingJumlahLantai = false;
                      });
                    },
                  ),
                  FormTextField(
                    controller: _lebarDepanController, 
                    label: "Lebar Depan (m)", 
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _isUserTypingLebarDepan = true;
                      formNotifier.onLebarDepanChanged(value);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingLebarDepan = false;
                      });
                    },
                  ),
                  FormTextField(
                    controller: _panjangController, 
                    label: "Panjang (m)", 
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _isUserTypingPanjang = true;
                      formNotifier.onPanjangChanged(value);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingPanjang = false;
                      });
                    },
                  ),
                  FormTextField(
                    controller: _luasController, 
                    label: "Luas (m2)", 
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _isUserTypingLuas = true;
                      formNotifier.onLuasChanged(value);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingLuas = false;
                      });
                    },
                  ),
                  FormTextField(
                    controller: _hargaSewaController, 
                    label: "Harga Sewa", 
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _isUserTypingHargaSewa = true;
                      formNotifier.onHargaSewaChanged(value);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingHargaSewa = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormCardSection(
                title: "Data Pemilik",
                iconAsset: "assets/icons/profile.svg",
                children: [
                  FormTextField(
                    controller: _namaPemilikController, 
                    label: "Nama Pemilik",
                    onChanged: formNotifier.onNamaPemilikChanged
                  ),
                  FormTextField(
                    controller: _kontakPemilikController, 
                    label: "Kontak Pemilik", 
                    keyboardType: TextInputType.phone,
                    onChanged: formNotifier.onKontakPemilikChanged
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
                    onSelected: (value) => formNotifier.onKarakterLokasiChanged(value!)
                  ),
                  PopupButtonForm(
                    label: "Sosial Ekonomi", 
                    optionsProvider: dropdownOptionsProvider('social'), 
                    selectedValue: formState.sosialEkonomi, 
                    onSelected: (value) => formNotifier.onSosialEkonomiChanged(value!)
                  ),
                  FormTextField(
                    controller: _skorFplController, 
                    label: "Skor FPL", 
                    keyboardType: TextInputType.number, 
                    onChanged: (value) {
                      _isUserTypingSkorFpl = true;
                      formNotifier.onSkorFplChanged(value);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingSkorFpl = false;
                      });
                    },
                  ),
                  FormTextField(
                    controller: _stdController, 
                    label: "STD", 
                    keyboardType: TextInputType.number, 
                    onChanged: (value) {
                      _isUserTypingStd = true;
                      formNotifier.onStdChanged(value);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingStd = false;
                      });
                    }
                  ),
                  FormTextField(
                    controller: _apcController, 
                    label: "APC", 
                    keyboardType: TextInputType.number, 
                    onChanged: (value) {
                      _isUserTypingApc = true;
                      formNotifier.onApcChanged(value);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingApc = false;
                      });
                    }
                  ),
                  FormTextField(
                    controller: _spdController, 
                    label: "SPD", 
                    keyboardType: TextInputType.number, 
                    onChanged: (value) {
                      _isUserTypingSpd = true;
                      formNotifier.onSpdChanged(value);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingSpd = false;
                      });
                    }
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
                    onSelected: (value) => formNotifier.onPeStatusChanged(value!)
                  ),
                  FormTextField(
                    controller: _peRabController, 
                    label: "PE RAB", 
                    keyboardType: TextInputType.number, 
                    onChanged: (value) {
                      _isUserTypingPeRab = true;
                      formNotifier.onPeRabChanged(value);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _isUserTypingPeRab = false;
                      });
                    }
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormCardSection(
                title: "Upload Dokumen",
                iconAsset: "assets/icons/lampiran.svg",
                children: [
                  FileUploadWidget(label: "PDF Foto", fileName: formState.pdfFoto?.path.split('/').last ?? formState.existingPdfFotoPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'pdfFoto')),
                  FileUploadWidget(label: "Counting Kompetitor", fileName: formState.countingKompetitor?.path.split('/').last ?? formState.existingCountingKompetitorPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'countingKompetitor')),
                  FileUploadWidget(label: "PDF Pembanding", fileName: formState.pdfPembanding?.path.split('/').last ?? formState.existingPdfPembandingPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'pdfPembanding')),
                  FileUploadWidget(label: "PDF KKS", fileName: formState.pdfKks?.path.split('/').last ?? formState.existingPdfKksPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'pdfKks')),
                  FileUploadWidget(label: "Excel FPL", fileName: formState.excelFpl?.path.split('/').last ?? formState.existingExcelFplPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'excelFpl')),
                  FileUploadWidget(label: "Excel PE", fileName: formState.excelPe?.path.split('/').last ?? formState.existingExcelPePath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'excelPe')),
                  FileUploadWidget(label: "PDF Form Ukur", fileName: formState.pdfFormUkur?.path.split('/').last ?? formState.existingPdfFormUkurPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'pdfFormUkur')),
                  FileUploadWidget(label: "Video Traffic Siang", fileName: formState.videoTrafficSiang?.path.split('/').last ?? formState.existingVideoTrafficSiangPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'videoTrafficSiang')),
                  FileUploadWidget(label: "Video Traffic Malam", fileName: formState.videoTrafficMalam?.path.split('/').last ?? formState.existingVideoTrafficMalamPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'videoTrafficMalam')),
                  FileUploadWidget(label: "Video 360 Siang", fileName: formState.video360Siang?.path.split('/').last ?? formState.existingVideo360SiangPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'video360Siang')),
                  FileUploadWidget(label: "Video 360 Malam", fileName: formState.video360Malam?.path.split('/').last ?? formState.existingVideo360MalamPath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'video360Malam')),
                  FileUploadWidget(label: "Peta Coverage", fileName: formState.petaCoverage?.path.split('/').last ?? formState.existingPetaCoveragePath?.split('/').last, onTap: () => pickFile(formNotifier.onFilePicked, 'petaCoverage')),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: formState.status == KpltFormStatus.loading ? null : () async {
                      // Tambahkan print statement untuk debugging
                      debugPrint("Update button pressed. Current state is being sent.");
                      if (_formKey.currentState?.validate() ?? false) {
                        final success = await formNotifier.updateForm(originalKplt: widget.kplt);
                        if (success && mounted) {
                          _showPopupAndNavigateBack("Data Berhasil Diupdate!", "assets/icons/success.svg");
                        }
                      } else {
                        debugPrint("Form validation failed.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: formState.status == KpltFormStatus.loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Data KPLT'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      )
    );
  }
}