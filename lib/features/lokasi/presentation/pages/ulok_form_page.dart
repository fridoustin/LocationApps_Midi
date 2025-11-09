import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/custom_success_dialog.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/core/widgets/file_upload.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_form_state.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_form_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/dropdown.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/map_picker.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/text_field.dart';
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';
import 'package:midi_location/features/wilayah/presentation/providers/wilayah_provider.dart';
import 'package:midi_location/features/wilayah/presentation/widgets/wilayah_dropdown.dart';

class UlokFormPage extends ConsumerStatefulWidget {
  final UlokFormState? initialState;
  const UlokFormPage({super.key, this.initialState});

  @override
  ConsumerState<UlokFormPage> createState() => _UlokFormPageState();
}

class _UlokFormPageState extends ConsumerState<UlokFormPage> {
  bool get _isEditMode => widget.initialState?.ulokId != null;
  final _formKey = GlobalKey<FormState>();
  late final MapController _mapController;

  // Controllers
  final _namaUlokC = TextEditingController();
  final _alamatC = TextEditingController();
  final _alasHakC = TextEditingController();
  final _jumlahLantaiC = TextEditingController();
  final _lebarDepanC = TextEditingController();
  final _panjangC = TextEditingController();
  final _luasC = TextEditingController();
  final _hargaSewaC = TextEditingController();
  final _namaPemilikC = TextEditingController();
  final _kontakPemilikC = TextEditingController();

  // Flags untuk tracking user typing
  bool _isUserTypingJumlahLantai = false;
  bool _isUserTypingLebarDepan = false;
  bool _isUserTypingPanjang = false;
  bool _isUserTypingLuas = false;
  bool _isUserTypingHargaSewa = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    final initialData = widget.initialState;
    if (initialData != null) {
      _namaUlokC.text = initialData.namaUlok ?? '';
      _alamatC.text = initialData.alamat ?? '';
      _alasHakC.text = initialData.alasHak ?? '';
      _jumlahLantaiC.text = initialData.jumlahLantai?.toString() ?? '';
      _lebarDepanC.text = initialData.lebarDepan?.toString() ?? '';
      _panjangC.text = initialData.panjang?.toString() ?? '';
      _luasC.text = initialData.luas?.toString() ?? '';
      _hargaSewaC.text = initialData.hargaSewa?.toString() ?? '';
      _namaPemilikC.text = initialData.namaPemilik ?? '';
      _kontakPemilikC.text = initialData.kontakPemilik ?? '';
    }
  }

  @override
  void dispose() {
    _namaUlokC.dispose();
    _alamatC.dispose();
    _alasHakC.dispose();
    _jumlahLantaiC.dispose();
    _lebarDepanC.dispose();
    _panjangC.dispose();
    _luasC.dispose();
    _hargaSewaC.dispose();
    _namaPemilikC.dispose();
    _kontakPemilikC.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _openMapDialog(UlokFormNotifier notifier, LatLng? currentLatLng) async { 
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Izin lokasi ditolak")));
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

  Future<void> _showPopupAndNavigateBack(String message, String iconPath) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomSuccessDialog(title: message, iconPath: iconPath),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainLayout(currentIndex: 1),
        ),
        (route) => false, 
      );
    }
  }

  String _formatNumber(num? number) {
    if (number == null) return '';
    if (number.truncateToDouble() == number) {
      return number.truncate().toString();
    }
    return number.toString();
  }

  void _updateControllerIfNeeded(
    TextEditingController controller,
    String newValue,
    bool isUserTyping,
  ) {
    // HANYA update jika user TIDAK sedang typing
    if (!isUserTyping && controller.text != newValue) {
      final selection = controller.selection;
      controller.text = newValue;
      // Maintain cursor position if possible
      if (selection.start <= newValue.length) {
        controller.selection = selection;
      }
    }
  }

  Widget _buildMapPreview(UlokFormState formState) {
    if (formState.latLng == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
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
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
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

  Widget _buildFileUploadCard(String label, String? fileName, String? existingUrl, VoidCallback onTap) {
    final hasFile = (fileName != null && fileName.isNotEmpty) || 
                    (existingUrl != null && existingUrl.isNotEmpty);

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
                        fileName ?? existingUrl?.split('/').last ?? '',
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
    final formProvider = ulokFormProvider(widget.initialState);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    ref.listen<UlokFormState>(formProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Update controllers HANYA jika user TIDAK sedang typing
        _updateControllerIfNeeded(
          _jumlahLantaiC,
          _formatNumber(next.jumlahLantai),
          _isUserTypingJumlahLantai,
        );
        
        _updateControllerIfNeeded(
          _lebarDepanC,
          _formatNumber(next.lebarDepan),
          _isUserTypingLebarDepan,
        );
        
        _updateControllerIfNeeded(
          _panjangC,
          _formatNumber(next.panjang),
          _isUserTypingPanjang,
        );
        
        _updateControllerIfNeeded(
          _luasC,
          _formatNumber(next.luas),
          _isUserTypingLuas,
        );

        _updateControllerIfNeeded(
          _hargaSewaC,
          _formatNumber(next.hargaSewa),
          _isUserTypingHargaSewa,
        );

        // Text fields tanpa bouncing issue
        if (previous?.namaUlok != next.namaUlok && _namaUlokC.text != next.namaUlok) {
          _namaUlokC.text = next.namaUlok ?? '';
        }
        if (previous?.alamat != next.alamat && _alamatC.text != next.alamat) {
          _alamatC.text = next.alamat ?? '';
        }
        if (previous?.alasHak != next.alasHak && _alasHakC.text != next.alasHak) {
          _alasHakC.text = next.alasHak ?? '';
        }
        if (previous?.namaPemilik != next.namaPemilik && _namaPemilikC.text != next.namaPemilik) {
          _namaPemilikC.text = next.namaPemilik ?? '';
        }
        if (previous?.kontakPemilik != next.kontakPemilik && _kontakPemilikC.text != next.kontakPemilik) {
          _kontakPemilikC.text = next.kontakPemilik ?? '';
        }

        // Handle status
        if (previous?.status != next.status) {
          if (next.status == UlokFormStatus.success) {
            _showPopupAndNavigateBack("Data Berhasil Disimpan!", "assets/icons/success.svg");
          } else if (next.status == UlokFormStatus.error && next.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red));
          }
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: _isEditMode ? 'Edit ULOK' : 'Form ULOK',
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Data Usulan Lokasi
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
                            "assets/icons/location.svg",
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
                          "Data Usulan Lokasi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FormTextField(
                      controller: _namaUlokC, 
                      label: 'Nama ULOK',
                      onChanged: formNotifier.onNamaUlokChanged,
                    ),
                    SearchableDropdown(
                      label: "Provinsi",
                      itemsProvider: provincesProvider,
                      selectedValue: formState.provinsi != null 
                          ? WilayahEntity(id: '', name: formState.provinsi!) 
                          : null,
                      onChanged: formNotifier.onProvinceSelected,
                    ),
                    SearchableDropdown(
                      label: "Kabupaten/Kota",
                      isEnabled: formState.provinsi != null,
                      itemsProvider: regenciesProvider,
                      selectedValue: formState.kabupaten != null 
                          ? WilayahEntity(id: '', name: formState.kabupaten!) 
                          : null,
                      onChanged: formNotifier.onRegencySelected,
                    ),
                    SearchableDropdown(
                      label: "Kecamatan",
                      isEnabled: formState.kabupaten != null,
                      itemsProvider: districtsProvider,
                      selectedValue: formState.kecamatan != null 
                          ? WilayahEntity(id: '', name: formState.kecamatan!) 
                          : null,
                      onChanged: formNotifier.onDistrictSelected,
                    ),
                    SearchableDropdown(
                      label: "Desa/Kelurahan",
                      isEnabled: formState.kecamatan != null,
                      itemsProvider: villagesProvider,
                      selectedValue: formState.desa != null 
                          ? WilayahEntity(id: '', name: formState.desa!) 
                          : null,
                      onChanged: formNotifier.onVillageSelected,
                    ),
                    FormTextField(
                      controller: _alamatC, 
                      label: 'Alamat', 
                      maxLines: 3, 
                      onChanged: formNotifier.onAlamatChanged,
                    ),
                    FormTextField(
                      controller: TextEditingController(
                        text: formState.latLng != null
                            ? '${formState.latLng!.latitude.toStringAsFixed(6)}, ${formState.latLng!.longitude.toStringAsFixed(6)}'
                            : '',
                      ),
                      label: 'Koordinat',
                      hint: 'Tap untuk pilih lokasi di peta',
                      readOnly: true,
                      onTap: () => _openMapDialog(formNotifier, formState.latLng),
                      suffixIcon: const Icon(
                        Icons.map,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    _buildMapPreview(formState),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Data Store
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
                          "Data Store",
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
                      label: 'Format Store',
                      optionsProvider: ulokDropdownOptionsProvider('format_store'),
                      selectedValue: formState.formatStore,
                      onSelected: (value) => formNotifier.onFormatStoreChanged(value!),
                    ),
                    PopupButtonForm(
                      label: 'Bentuk Objek',
                      optionsProvider: ulokDropdownOptionsProvider('bentuk_objek'),
                      selectedValue: formState.bentukObjek,
                      onSelected: (value) => formNotifier.onBentukObjekChanged(value!),
                    ),
                    FormTextField(
                      controller: _alasHakC, 
                      label: 'Alas Hak', 
                      onChanged: formNotifier.onAlasHakChanged,
                    ),
                    FormTextField(
                      controller: _jumlahLantaiC, 
                      label: 'Jumlah Lantai', 
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _isUserTypingJumlahLantai = true;
                        formNotifier.onJumlahLantaiChanged(value);
                        // Reset flag setelah 500ms
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() => _isUserTypingJumlahLantai = false);
                          }
                        });
                      },
                    ),
                    FormTextField(
                      controller: _lebarDepanC, 
                      label: 'Lebar Depan (m)', 
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _isUserTypingLebarDepan = true;
                        formNotifier.onLebarDepanChanged(value);
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() => _isUserTypingLebarDepan = false);
                          }
                        });
                      },
                    ),
                    FormTextField(
                      controller: _panjangC, 
                      label: 'Panjang (m)', 
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _isUserTypingPanjang = true;
                        formNotifier.onPanjangChanged(value);
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() => _isUserTypingPanjang = false);
                          }
                        });
                      },
                    ),
                    FormTextField(
                      controller: _luasC, 
                      label: 'Luas (m²)', 
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _isUserTypingLuas = true;
                        formNotifier.onLuasChanged(value);
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() => _isUserTypingLuas = false);
                          }
                        });
                      },
                    ),
                    FormTextField(
                      controller: _hargaSewaC, 
                      label: 'Harga Sewa (+PPH 10%)', 
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _isUserTypingHargaSewa = true;
                        formNotifier.onHargaSewaChanged(value);
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() => _isUserTypingHargaSewa = false);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Data Pemilik
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
                            "assets/icons/avatar.svg",
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
                          "Data Pemilik",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FormTextField(
                      controller: _namaPemilikC, 
                      label: 'Nama Pemilik', 
                      onChanged: formNotifier.onNamaPemilikChanged,
                    ),
                    FormTextField(
                      controller: _kontakPemilikC, 
                      label: 'Kontak Pemilik', 
                      keyboardType: TextInputType.phone, 
                      onChanged: formNotifier.onKontakPemilikChanged,
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
                            "assets/icons/upload.svg",
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
                      "Formulir Usulan Lokasi (PDF)",
                      formState.formUlokPdf?.path.split('/').last,
                      formState.existingFormUlokUrl,
                      () async {
                        await pickFile(
                          (fieldName, file) => formNotifier.onFilePicked(file), 
                          '',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  if (!_isEditMode) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: formState.status == UlokFormStatus.loading
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
                          side: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
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
                  ],
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: formState.status == UlokFormStatus.loading 
                          ? null 
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                formNotifier.submitOrUpdateForm();
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
                      child: formState.status == UlokFormStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEditMode ? 'Update Data' : 'Submit',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}