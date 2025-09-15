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
import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';
import 'package:midi_location/features/wilayah/presentation/providers/wilayah_provider.dart';
import 'package:midi_location/features/wilayah/presentation/widgets/wilayah_dropdown.dart';
import 'package:uuid/uuid.dart';

class UlokFormPage extends ConsumerStatefulWidget {
  final UlokFormData? draftData;
  const UlokFormPage({super.key, this.draftData});

  @override
  ConsumerState<UlokFormPage> createState() => _UlokFormPageState();
}

class _UlokFormPageState extends ConsumerState<UlokFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final MapController _mapController;
  late final String _currentLocalId;

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

  WilayahEntity? _selectedProvince;
  WilayahEntity? _selectedRegency;
  WilayahEntity? _selectedDistrict;
  WilayahEntity? _selectedVillage;

  // State
  String? _selectedFormatStore;
  String? _selectedBentukObjek;
  LatLng? _currentLatLng;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLocalId = widget.draftData?.localId ?? const Uuid().v4();

    if (widget.draftData != null) {
      final data = widget.draftData!;
      _namaUlokC.text = data.namaUlok;
      _alamatC.text = data.alamat;
      _latLngC.text = "${data.latLng.latitude}, ${data.latLng.longitude}";
      _currentLatLng = data.latLng;
      _selectedProvince = WilayahEntity(id: '', name: data.provinsi);
      _selectedRegency = WilayahEntity(id: '', name: data.kabupaten);
      _selectedDistrict = WilayahEntity(id: '', name: data.kecamatan);
      _selectedVillage = WilayahEntity(id: '', name: data.desa);
      _selectedFormatStore = data.formatStore;
      _selectedBentukObjek = data.bentukObjek;
      _alasHakC.text = data.alasHak;
      _jumlahLantaiC.text = data.jumlahLantai.toString();
      _lebarDepanC.text = data.lebarDepan.toString();
      _panjangC.text = data.panjang.toString();
      _luasC.text = data.luas.toString();
      _hargaSewaC.text = data.hargaSewa.toString();
      _namaPemilikC.text = data.namaPemilik;
      _kontakPemilikC.text = data.kontakPemilik;
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

    final LatLng? selectedLatLng = await showDialog<LatLng>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => const MapPickerDialog(),
    );

    if (selectedLatLng != null) {
      setState(() {
        _currentLatLng = selectedLatLng;
        _latLngC.text =
            "${selectedLatLng.latitude.toStringAsFixed(6)}, ${selectedLatLng.longitude.toStringAsFixed(6)}";
      });
    }
  }

  Future<void> _showSuccessAndNavigateBack() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  color: AppColors.successColor, size: 80),
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

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) Navigator.of(context).pop();
    if (mounted) Navigator.of(context).pop();
  }

  UlokFormData _collectFormData() {
    return UlokFormData(
      localId: _currentLocalId, // Selalu sertakan ID lokal saat ini
      namaUlok: _namaUlokC.text,
      latLng: _currentLatLng ?? LatLng(0, 0),
      provinsi: _selectedProvince?.name ?? '',
      kabupaten: _selectedRegency?.name ?? '',
      kecamatan: _selectedDistrict?.name ?? '',
      desa: _selectedVillage?.name ?? '',
      alamat: _alamatC.text,
      formatStore: _selectedFormatStore ?? '',
      bentukObjek: _selectedBentukObjek ?? '',
      alasHak: _alasHakC.text,
      jumlahLantai: int.tryParse(_jumlahLantaiC.text) ?? 0,
      lebarDepan: double.tryParse(_lebarDepanC.text) ?? 0.0,
      panjang: double.tryParse(_panjangC.text) ?? 0.0,
      luas: double.tryParse(_luasC.text) ?? 0.0,
      hargaSewa: double.tryParse(_hargaSewaC.text) ?? 0.0,
      namaPemilik: _namaPemilikC.text,
      kontakPemilik: _kontakPemilikC.text,
    );
  }

  void _onSaveDraft() {
    final formData = _collectFormData();
    ref.read(ulokFormProvider.notifier).saveDraft(formData).then((success) {
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil disimpan di Draft!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    });
  }

  void _onSubmit() {
    if ((_formKey.currentState?.validate() ?? false) && _currentLatLng != null) {
      final formData = _collectFormData();
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
                  SearchableDropdown(
                    label: "Provinsi *",
                    itemsProvider: provincesProvider,
                    selectedValue: _selectedProvince,
                    onChanged: (newValue) {
                      // update local state & providers
                      setState(() {
                        _selectedProvince = newValue;
                        _selectedRegency = null;
                        _selectedDistrict = null;
                        _selectedVillage = null;
                      });
                      print('DEBUG selectedProvince => id: ${newValue?.id}, name: ${newValue?.name}');
                      if (newValue != null && newValue.id.isNotEmpty) {
                        ref.read(selectedProvinceProvider.notifier).state = newValue;
                        // invalidate downstream so regenciesProvider refetches with proper id
                        ref.invalidate(regenciesProvider);
                      } else {
                        ref.read(selectedProvinceProvider.notifier).state = null;
                        ref.invalidate(regenciesProvider);
                      }

                      // reset downstream provider states
                      ref.read(selectedRegencyProvider.notifier).state = null;
                      ref.read(selectedDistrictProvider.notifier).state = null;
                      ref.read(selectedVillageProvider.notifier).state = null;
                    },
                  ),
                  SearchableDropdown(
                    label: "Kabupaten/Kota *",
                    isEnabled: _selectedProvince != null,
                    itemsProvider: regenciesProvider,
                    selectedValue: _selectedRegency,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedRegency = newValue;
                        _selectedDistrict = null;
                        _selectedVillage = null;
                      });

                      // Debug
                      // ignore: avoid_print
                      print('DEBUG selectedRegency => id: ${newValue?.id}, name: ${newValue?.name}');

                      if (newValue != null && newValue.id.isNotEmpty) {
                        ref.read(selectedRegencyProvider.notifier).state = newValue;
                        ref.invalidate(districtsProvider);
                      } else {
                        ref.read(selectedRegencyProvider.notifier).state = null;
                        ref.invalidate(districtsProvider);
                      }

                      ref.read(selectedDistrictProvider.notifier).state = null;
                      ref.read(selectedVillageProvider.notifier).state = null;
                    },
                  ),
                  SearchableDropdown(
                    label: "Kecamatan *",
                    isEnabled: _selectedRegency != null,
                    itemsProvider: districtsProvider,
                    selectedValue: _selectedDistrict,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDistrict = newValue;
                        _selectedVillage = null;
                      });

                      // Debug
                      // ignore: avoid_print
                      print('DEBUG selectedDistrict => id: ${newValue?.id}, name: ${newValue?.name}');

                      if (newValue != null && newValue.id.isNotEmpty) {
                        ref.read(selectedDistrictProvider.notifier).state = newValue;
                        ref.invalidate(villagesProvider);
                      } else {
                        ref.read(selectedDistrictProvider.notifier).state = null;
                        ref.invalidate(villagesProvider);
                      }

                      ref.read(selectedVillageProvider.notifier).state = null;
                    },
                  ),
                  SearchableDropdown(
                    label: "Desa/Kelurahan *",
                    isEnabled: _selectedDistrict != null,
                    itemsProvider: villagesProvider,
                    selectedValue: _selectedVillage,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedVillage = newValue;
                      });

                      // Debug
                      // ignore: avoid_print
                      print('DEBUG selectedVillage => id: ${newValue?.id}, name: ${newValue?.name}');

                      // juga update provider
                      if (newValue != null && newValue.id.isNotEmpty) {
                        ref.read(selectedVillageProvider.notifier).state = newValue;
                      } else {
                        ref.read(selectedVillageProvider.notifier).state = null;
                      }
                    },
                  ),
                  FormTextField(controller: _alamatC, label: 'Alamat', maxLines: 3),
                  FormTextField(
                    controller: _latLngC,
                    label: 'Latlong',
                    readOnly: true,
                    onTap: _openMapDialog,
                    suffixIcon: IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/location.svg",
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
                      onPressed: formState.action == FormAction.none ? _onSaveDraft : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardColor,
                        foregroundColor: AppColors.primaryColor,
                        side: const BorderSide(color: AppColors.primaryColor),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: formState.action == FormAction.savingDraft
                          ? const CircularProgressIndicator(color: AppColors.primaryColor)
                          : const Text('Simpan Draft'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: formState.action == FormAction.none ? _onSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: formState.action == FormAction.submitting
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
