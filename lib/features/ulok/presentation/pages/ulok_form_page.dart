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
import 'package:midi_location/features/ulok/domain/entities/ulok_form_state.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_form_provider.dart';
import 'package:midi_location/features/ulok/presentation/widgets/dropdown.dart';
import 'package:midi_location/features/ulok/presentation/widgets/form_card.dart';
import 'package:midi_location/features/ulok/presentation/widgets/map_picker.dart';
import 'package:midi_location/features/ulok/presentation/widgets/text_field.dart';
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
  final _latLngC = TextEditingController();
  final _alasHakC = TextEditingController();
  final _jumlahLantaiC = TextEditingController();
  final _lebarDepanC = TextEditingController();
  final _panjangC = TextEditingController();
  final _luasC = TextEditingController();
  final _hargaSewaC = TextEditingController();
  final _namaPemilikC = TextEditingController();
  final _kontakPemilikC = TextEditingController();

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
    _latLngC.dispose();
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
      // ignore: use_build_context_synchronously
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

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainLayout(currentIndex: 1),
        ),
        (route) => false, 
      );
    }
  }

  Widget _buildMapPreview(UlokFormState formState) { // aman
    if (formState.latLng == null) {
      return const SizedBox.shrink();
    }
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

  @override
  Widget build(BuildContext context) {
    final formProvider = ulokFormProvider(widget.initialState);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    ref.listen<UlokFormState>(formProvider, (previous, next) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        String formatNumber(num? number) {
          if (number == null) return '';
          if (number.truncateToDouble() == number) {
            return number.truncate().toString();
          }
          return number.toString();
        }

        final nextJumlahLantai = formatNumber(next.jumlahLantai);
        if (_jumlahLantaiC.text != nextJumlahLantai) {
          _jumlahLantaiC.text = nextJumlahLantai;
        }
        
        final nextLebarDepan = formatNumber(next.lebarDepan);
        if (_lebarDepanC.text != nextLebarDepan) {
          _lebarDepanC.text = nextLebarDepan;
        }
        
        final nextPanjang = formatNumber(next.panjang);
        if (_panjangC.text != nextPanjang) {
          _panjangC.text = nextPanjang;
        }
        
        final nextLuas = formatNumber(next.luas);
        if (_luasC.text != nextLuas) {
          _luasC.text = nextLuas;
        }

        final nextHargaSewa = formatNumber(next.hargaSewa);
        if (_hargaSewaC.text != nextHargaSewa) {
          _hargaSewaC.text = nextHargaSewa;
        }
        // Sinkronkan controller jika ada perubahan dari state (misal: saat draft dimuat)
        if (previous?.namaUlok != next.namaUlok) _namaUlokC.text = next.namaUlok ?? '';
        if (previous?.alamat != next.alamat) _alamatC.text = next.alamat ?? '';
        if (previous?.alasHak != next.alasHak) _alasHakC.text = next.alasHak ?? '';
        if (previous?.namaPemilik != next.namaPemilik) _namaPemilikC.text = next.namaPemilik ?? '';
        if (previous?.kontakPemilik != next.kontakPemilik) _kontakPemilikC.text = next.kontakPemilik ?? '';

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
        title: 'Form ULOK',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FormCardSection(
                title: "Data Usulan Lokasi",
                iconAsset: "assets/icons/location.svg",
                children: [
                  FormTextField(
                    controller: _namaUlokC, 
                    label: 'Nama ULOK',
                    onChanged: formNotifier.onNamaUlokChanged,
                  ),
                  SearchableDropdown(
                    label: "Provinsi",
                    itemsProvider: provincesProvider,
                    selectedValue: formState.provinsi != null ? WilayahEntity(id: '', name: formState.provinsi!) : null,
                    onChanged: formNotifier.onProvinceSelected,
                  ),
                  SearchableDropdown(
                    label: "Kabupaten/Kota",
                    isEnabled: formState.provinsi != null,
                    itemsProvider: regenciesProvider,
                    selectedValue: formState.kabupaten != null ? WilayahEntity(id: '', name: formState.kabupaten!) : null,
                    onChanged: formNotifier.onRegencySelected,
                  ),
                  SearchableDropdown(
                    label: "Kecamatan",
                    isEnabled: formState.kabupaten != null,
                    itemsProvider: districtsProvider,
                    selectedValue: formState.kecamatan != null ? WilayahEntity(id: '', name: formState.kecamatan!) : null,
                    onChanged: formNotifier.onDistrictSelected,
                  ),
                  SearchableDropdown(
                    label: "Desa/Kelurahan",
                    isEnabled: formState.kecamatan != null,
                    itemsProvider: villagesProvider,
                    selectedValue: formState.desa != null ? WilayahEntity(id: '', name: formState.desa!) : null,
                    onChanged: formNotifier.onVillageSelected,
                  ),
                  FormTextField(
                    controller: _alamatC, 
                    label: 'Alamat', 
                    maxLines: 3, 
                    onChanged: formNotifier.onAlamatChanged
                  ),
                  FormTextField(
                    controller: TextEditingController(
                      text: formState.latLng != null
                          ? '${formState.latLng!.latitude.toStringAsFixed(6)}, ${formState.latLng!.longitude.toStringAsFixed(6)}'
                          : '',
                    ),
                    label: 'Latlong',
                    readOnly: true,
                    onTap: () => _openMapDialog(formNotifier, formState.latLng),
                  ),
                  _buildMapPreview(formState),
                ],
              ),
              const SizedBox(height: 20),
              FormCardSection(
                title: "Data Store",
                iconAsset: "assets/icons/data_store.svg",
                children: [
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
                  FormTextField(controller: _alasHakC, label: 'Alas Hak', onChanged: formNotifier.onAlasHakChanged),
                  FormTextField(controller: _jumlahLantaiC, label: 'Jumlah Lantai', keyboardType: TextInputType.number, onChanged: formNotifier.onJumlahLantaiChanged),
                  FormTextField(controller: _lebarDepanC, label: 'Lebar Depan (m)', keyboardType: TextInputType.number, onChanged: formNotifier.onLebarDepanChanged),
                  FormTextField(controller: _panjangC, label: 'Panjang (m)', keyboardType: TextInputType.number, onChanged: formNotifier.onPanjangChanged),
                  FormTextField(controller: _luasC, label: 'Luas (m2)', keyboardType: TextInputType.number, onChanged: formNotifier.onLuasChanged),
                  FormTextField(controller: _hargaSewaC, label: 'Harga Sewa (+PPH 10%)', keyboardType: TextInputType.number, onChanged: formNotifier.onHargaSewaChanged),
                ],
              ),
              const SizedBox(height: 20),
              FormCardSection(
                title: "Data Pemilik",
                iconAsset: "assets/icons/avatar.svg",
                children: [
                  FormTextField(controller: _namaPemilikC, label: 'Nama Pemilik', onChanged: formNotifier.onNamaPemilikChanged),
                  FormTextField(controller: _kontakPemilikC, label: 'Kontak Pemilik', keyboardType: TextInputType.phone, onChanged: formNotifier.onKontakPemilikChanged),
                ],
              ),
              const SizedBox(height: 20),
              FormCardSection(
                title: "Upload Dokumen",
                iconAsset: "assets/icons/upload.svg",
                children: [
                  FileUploadWidget(
                    label: "Formulir Usulan Lokasi (PDF)",
                    fileName: formState.formUlokPdf?.path.split('/').last,
                    existingFileUrl: formState.existingFormUlokUrl,
                    onTap: () async {
                      await pickFile((fieldName, file) => formNotifier.onFilePicked(file), '');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child : Row(
                  children: [
                    if (widget.initialState?.ulokId == null) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
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
                    ],
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: formState.status == UlokFormStatus.loading ? null : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            formNotifier.submitOrUpdateForm();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: formState.status == UlokFormStatus.loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            // Ganti teks tombol berdasarkan mode Create vs. Edit
                            : Text(_isEditMode ? 'Update Data' : 'Submit'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
