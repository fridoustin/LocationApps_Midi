import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_form_provider.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_provider.dart';
import 'package:midi_location/features/ulok/presentation/widgets/dropdown.dart';
import 'package:midi_location/features/ulok/presentation/widgets/form_card.dart';
import 'package:midi_location/features/ulok/presentation/widgets/map_picker.dart';
import 'package:midi_location/features/ulok/presentation/widgets/text_field.dart';

class UlokFormPage extends ConsumerStatefulWidget {
  const UlokFormPage({super.key});

  @override
  ConsumerState<UlokFormPage> createState() => _UlokFormPageState();
}

class _UlokFormPageState extends ConsumerState<UlokFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final MapController _mapController;

  // Controllers
  final _namaUlokC = TextEditingController();
  final _provinsiC = TextEditingController();
  final _kabupatenC = TextEditingController();
  final _kecamatanC = TextEditingController();
  final _desaC = TextEditingController();
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

  // State
  String? _selectedFormatStore;
  String? _selectedBentukObjek;
  LatLng? _currentLatLng;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _namaUlokC.dispose(); _provinsiC.dispose(); _kabupatenC.dispose();
    _kecamatanC.dispose(); _desaC.dispose(); _alamatC.dispose();
    _alasHakC.dispose(); _jumlahLantaiC.dispose(); _lebarDepanC.dispose();
    _panjangC.dispose(); _luasC.dispose(); _hargaSewaC.dispose();
    _namaPemilikC.dispose(); _kontakPemilikC.dispose(); _latLngC.dispose();
    _mapController.dispose();
    super.dispose();
  }
  // --- LOGIKA MAP DIALOG DITAMBAHKAN KEMBALI DI SINI ---
  Future<void> _openMapDialog() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Izin lokasi ditolak")));
      }
      return;
    }

    // Tampilkan dialog dan tunggu hasilnya (LatLng)
    final LatLng? selectedLatLng = await showDialog<LatLng>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => const MapPickerDialog(), // Gunakan widget dialog terpisah
    );

    // Jika pengguna memilih lokasi, update state
    if (selectedLatLng != null) {
      setState(() {
        _currentLatLng = selectedLatLng;
        _latLngC.text =
            "${selectedLatLng.latitude.toStringAsFixed(6)}, ${selectedLatLng.longitude.toStringAsFixed(6)}";
      });
    }
  }

  Future<void> _showSuccessAndNavigateBack() async {
    // Tampilkan dialog pop-up
    showDialog(
      context: context,
      barrierDismissible: false, // Pengguna tidak bisa menutup dialog dengan menekan luar
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.successColor, size: 80),
              SizedBox(height: 16),
              Text(
                'Berhasil Disubmit!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );

    // Tunggu selama 3 detik
    await Future.delayed(const Duration(seconds: 3));

    // Tutup dialog pop-up
    if (mounted) Navigator.of(context).pop();
    // Kembali ke halaman sebelumnya (ULOK Page)
    if (mounted) Navigator.of(context).pop();
  }

  void _onSubmit() {
    if ((_formKey.currentState?.validate() ?? false) && _currentLatLng != null) {
      final formData = UlokFormData(
        namaUlok: _namaUlokC.text,
        latLng: _currentLatLng!,
        provinsi: _provinsiC.text,
        kabupaten: _kabupatenC.text,
        kecamatan: _kecamatanC.text,
        desa: _desaC.text,
        alamat: _alamatC.text,
        formatStore: _selectedFormatStore!,
        bentukObjek: _selectedBentukObjek!,
        alasHak: _alasHakC.text,
        jumlahLantai: int.tryParse(_jumlahLantaiC.text) ?? 0,
        lebarDepan: double.tryParse(_lebarDepanC.text) ?? 0.0,
        panjang: double.tryParse(_panjangC.text) ?? 0.0,
        luas: double.tryParse(_luasC.text) ?? 0.0,
        hargaSewa: double.tryParse(_hargaSewaC.text) ?? 0.0,
        namaPemilik: _namaPemilikC.text,
        kontakPemilik: _kontakPemilikC.text,
      );

      ref.read(ulokFormProvider.notifier).submitForm(formData).then((success) {
        if (success && mounted) {
          ref.invalidate(ulokListProvider);
          ref.invalidate(dashboardStatsProvider);
          _showSuccessAndNavigateBack();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap lengkapi semua data wajib, termasuk Latlong.'),
      ));
    }
  }

  Widget _buildMapPreview() {
    if (_currentLatLng == null) {
      return const SizedBox.shrink(); // Jika belum ada lokasi, jangan tampilkan apa-apa
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
              initialCenter: _currentLatLng!,
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
                    point: _currentLatLng!,
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
                          foregroundColor: AppColors.textColor,
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
                          foregroundColor: AppColors.textColor,
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
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(ulokFormProvider);

    ref.listen<UlokFormState>(ulokFormProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${next.errorMessage}'),
          backgroundColor: AppColors.errorColor,
        ));
      }
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
                  FormTextField(controller: _namaUlokC, label: 'Nama ULOK'),
                  FormTextField(controller: _provinsiC, label: 'Provinsi'),
                  FormTextField(controller: _kabupatenC, label: 'Kabupaten/Kota'),
                  FormTextField(controller: _kecamatanC, label: 'Kecamatan'),
                  FormTextField(controller: _desaC, label: 'Kelurahan/Desa'),
                  FormTextField(controller: _alamatC, label: 'Alamat', maxLines: 3),
                  FormTextField(
                    controller: _latLngC,
                    label: 'Latlong',
                    readOnly: true,
                    onTap: _openMapDialog,
                    suffixIcon: IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/location.svg", // <-- Ganti dengan path SVG Anda
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: _openMapDialog,
                    ),
                  ),
                  _buildMapPreview(),
                ],
              ),
              const SizedBox(height: 20),
              FormCardSection(
                title: "Data Store",
                iconAsset: "assets/icons/data_store.svg",
                children: [
                  PopupButtonForm(
                    label: 'Format Store',
                    optionsProvider: formatStoreOptionsProvider,
                    selectedValue: _selectedFormatStore,
                    onSelected: (value) => setState(() => _selectedFormatStore = value),
                  ),
                  PopupButtonForm(
                    label: 'Bentuk Objek',
                    optionsProvider: bentukObjekOptionsProvider,
                    selectedValue: _selectedBentukObjek,
                    onSelected: (value) => setState(() => _selectedBentukObjek = value),
                  ),
                  FormTextField(controller: _alasHakC, label: 'Alas Hak'),
                  FormTextField(controller: _jumlahLantaiC, label: 'Jumlah Lantai', keyboardType: TextInputType.number),
                  FormTextField(controller: _lebarDepanC, label: 'Lebar Depan (m)', keyboardType: TextInputType.number),
                  FormTextField(controller: _panjangC, label: 'Panjang (m)', keyboardType: TextInputType.number),
                  FormTextField(controller: _luasC, label: 'Luas (m2)', keyboardType: TextInputType.number),
                  FormTextField(controller: _hargaSewaC, label: 'Harga Sewa (+PPH 10%)', keyboardType: TextInputType.number),
                ],
              ),
              const SizedBox(height: 20),
              FormCardSection(
                title: "Data Pemilik",
                iconAsset: "assets/icons/avatar.svg",
                children: [
                  FormTextField(controller: _namaPemilikC, label: 'Nama Pemilik'),
                  FormTextField(controller: _kontakPemilikC, label: 'Kontak Pemilik', keyboardType: TextInputType.phone),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: formState.isLoading ? null : () {},
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
                      onPressed: formState.isLoading ? null : _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: formState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}