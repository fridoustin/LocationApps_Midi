// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:midi_location/core/constants/color.dart';
// import 'package:midi_location/core/widgets/topbar.dart';
// import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
// import 'package:midi_location/features/ulok/domain/entities/ulok_form.dart';
// import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
// import 'package:midi_location/features/ulok/presentation/providers/ulok_form_provider.dart';
// import 'package:midi_location/features/ulok/presentation/providers/ulok_provider.dart';
// import 'package:midi_location/features/ulok/presentation/widgets/dropdown.dart';
// import 'package:midi_location/features/ulok/presentation/widgets/form_card.dart';
// import 'package:midi_location/features/ulok/presentation/widgets/map_picker.dart';
// import 'package:midi_location/features/ulok/presentation/widgets/text_field.dart';
// import 'package:midi_location/features/wilayah/domain/entities/wilayah.dart';
// import 'package:midi_location/features/wilayah/presentation/providers/wilayah_provider.dart';
// import 'package:midi_location/features/wilayah/presentation/widgets/wilayah_dropdown.dart';

// class UlokEditPage extends ConsumerStatefulWidget {
//   final UsulanLokasi ulok;
//   const UlokEditPage({super.key, required this.ulok});

//   @override
//   ConsumerState<UlokEditPage> createState() => _UlokEditPageState();
// }

// class _UlokEditPageState extends ConsumerState<UlokEditPage> {
//   final _formKey = GlobalKey<FormState>();
//   late final MapController _mapController;

//   // Controllers
//   late final TextEditingController _namaUlokC, _alamatC, _alasHakC, _jumlahLantaiC,
//       _lebarDepanC, _panjangC, _luasC, _hargaSewaC, _namaPemilikC, _kontakPemilikC, _latLngC;

//   // State
//   String? _selectedFormatStore, _selectedBentukObjek;
//   LatLng? _currentLatLng;
//   WilayahEntity? _selectedProvince, _selectedRegency, _selectedDistrict, _selectedVillage;
//   bool _isInitializing = true;

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     _namaUlokC = TextEditingController(text: widget.ulok.namaLokasi);
//     _alamatC = TextEditingController(text: widget.ulok.alamat);
//     _alasHakC = TextEditingController(text: widget.ulok.alasHak);
//     _jumlahLantaiC = TextEditingController(text: widget.ulok.jumlahLantai?.toString());
//     _lebarDepanC = TextEditingController(text: widget.ulok.lebarDepan?.toString());
//     _panjangC = TextEditingController(text: widget.ulok.panjang?.toString());
//     _luasC = TextEditingController(text: widget.ulok.luas?.toString());
//     _hargaSewaC = TextEditingController(text: widget.ulok.hargaSewa?.toString());
//     _namaPemilikC = TextEditingController(text: widget.ulok.namaPemilik);
//     _kontakPemilikC = TextEditingController(text: widget.ulok.kontakPemilik);
//     _latLngC = TextEditingController(text: widget.ulok.latLong);
//     _selectedFormatStore = widget.ulok.formatStore;
//     _selectedBentukObjek = widget.ulok.bentukObjek;
//     final latLngParts = widget.ulok.latLong?.split(',') ?? ['0', '0'];
//     _currentLatLng = LatLng(double.tryParse(latLngParts[0]) ?? 0.0, double.tryParse(latLngParts[1]) ?? 0.0);
    
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if(mounted) _initializeWilayahData();
//     });
//   }

//   Future<void> _initializeWilayahData() async {
//     try {
//       final provinces = await ref.read(provincesProvider.future);
//       final initialProvince = provinces.firstWhere((p) => p.name.toLowerCase() == widget.ulok.provinsi.toLowerCase());
//       ref.read(selectedProvinceProvider.notifier).state = initialProvince;
      
//       final regencies = await ref.read(regenciesProvider.future);
//       final initialRegency = regencies.firstWhere((r) => r.name.toLowerCase() == widget.ulok.kabupaten.toLowerCase());
//       ref.read(selectedRegencyProvider.notifier).state = initialRegency;

//       final districts = await ref.read(districtsProvider.future);
//       final initialDistrict = districts.firstWhere((d) => d.name.toLowerCase() == widget.ulok.kecamatan.toLowerCase());
//       ref.read(selectedDistrictProvider.notifier).state = initialDistrict;

//       final villages = await ref.read(villagesProvider.future);
//       final initialVillage = villages.firstWhere((v) => v.name.toLowerCase() == widget.ulok.desaKelurahan.toLowerCase());
      
//       if (mounted) {
//         setState(() {
//           _selectedProvince = initialProvince;
//           _selectedRegency = initialRegency;
//           _selectedDistrict = initialDistrict;
//           _selectedVillage = initialVillage;
//           _isInitializing = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat data wilayah awal: $e")));
//         setState(() => _isInitializing = false);
//       }
//     }
//   }

//   Future<void> _openMapDialog() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Izin lokasi ditolak")));
//       }
//       return;
//     }

//     final LatLng? selectedLatLng = await showDialog<LatLng>(
//       // ignore: use_build_context_synchronously
//       context: context,
//       builder: (context) => const MapPickerDialog(),
//     );

//     if (selectedLatLng != null) {
//       setState(() {
//         _currentLatLng = selectedLatLng;
//         _latLngC.text =
//             "${selectedLatLng.latitude.toStringAsFixed(6)}, ${selectedLatLng.longitude.toStringAsFixed(6)}";
//       });
//     }
//   }

//   Future<void> _showSuccessAndNavigateBack() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(16.0)),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.check_circle_outline,
//                   color: AppColors.successColor, size: 70),
//               SizedBox(height: 16),
//               Text(
//                 'Berhasil Diupdate!',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         );
//       },
//     );

//     await Future.delayed(const Duration(seconds: 3));

//     if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
//   }
  
//   void _onUpdate() {
//     if (_formKey.currentState?.validate() ?? false) {
//       final formData = UlokFormData(
//         localId: widget.ulok.id,
//         namaUlok: _namaUlokC.text,
//         latLng: _currentLatLng!,
//         provinsi: _selectedProvince!.name,
//         kabupaten: _selectedRegency!.name,
//         kecamatan: _selectedDistrict!.name,
//         desa: _selectedVillage!.name,
//         alamat: _alamatC.text,
//         formatStore: _selectedFormatStore!,
//         bentukObjek: _selectedBentukObjek!,
//         alasHak: _alasHakC.text,
//         jumlahLantai: int.tryParse(_jumlahLantaiC.text) ?? 0,
//         lebarDepan: double.tryParse(_lebarDepanC.text) ?? 0.0,
//         panjang: double.tryParse(_panjangC.text) ?? 0.0,
//         luas: double.tryParse(_luasC.text) ?? 0.0,
//         hargaSewa: double.tryParse(_hargaSewaC.text) ?? 0.0,
//         namaPemilik: _namaPemilikC.text,
//         kontakPemilik: _kontakPemilikC.text,
//       );

//       ref.read(ulokEditProvider.notifier).updateUlok(widget.ulok.id, formData).then((success) {
//         if (success && mounted) {
//           ref.invalidate(ulokListProvider);
//           ref.invalidate(dashboardStatsProvider);
//           _showSuccessAndNavigateBack();
//         }
//       });
//     }
//   }
  
//   @override
//   void dispose() {
//     _mapController.dispose();
//     _namaUlokC.dispose();
//     _alamatC.dispose();
//     _alasHakC.dispose();
//     _jumlahLantaiC.dispose();
//     _lebarDepanC.dispose();
//     _panjangC.dispose();
//     _luasC.dispose();
//     _hargaSewaC.dispose();
//     _namaPemilikC.dispose();
//     _kontakPemilikC.dispose();
//     _latLngC.dispose();
//     super.dispose();
//   }

//   Widget _buildMapPreview() {
//     if (_currentLatLng == null) {
//       return const SizedBox.shrink();
//     }
//     return Padding(
//       padding: const EdgeInsets.only(top: 16.0),
//       child: SizedBox(
//         height: 200,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _currentLatLng!,
//               initialZoom: 16,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.midi.location',
//               ),
//               MarkerLayer(
//                 markers: [
//                   Marker(
//                     point: _currentLatLng!,
//                     width: 80,
//                     height: 80,
//                     child: const Icon(
//                       Icons.location_on,
//                       color: AppColors.primaryColor,
//                       size: 40,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return const Scaffold(appBar: null, body: Center(child: CircularProgressIndicator()));
//     }

//     final editState = ref.watch(ulokEditProvider);
//     ref.listen<UlokEditState>(ulokEditProvider, (prev, next) {
//       if (next.errorMessage != null) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${next.errorMessage}')));
//       }
//     });

//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: CustomTopBar.general(
//         title: 'Form ULOK',
//         showNotificationButton: false,
//         leadingWidget: IconButton(
//           icon: SvgPicture.asset(
//             "assets/icons/left_arrow.svg",
//             width: 24,
//             height: 24,
//             colorFilter: const ColorFilter.mode(
//               Colors.white,
//               BlendMode.srcIn,
//             ),
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               FormCardSection(
//                 title: "Data Usulan Lokasi",
//                 iconAsset: "assets/icons/location.svg",
//                 children: [
//                   FormTextField(controller: _namaUlokC, label: 'Nama ULOK'),
//                   SearchableDropdown(
//                     label: "Provinsi *",
//                     itemsProvider: provincesProvider,
//                     selectedValue: _selectedProvince,
//                     onChanged: (newValue) {
//                       setState(() {
//                         _selectedProvince = newValue;
//                         _selectedRegency = null; _selectedDistrict = null; _selectedVillage = null;
//                       });
//                       ref.read(selectedProvinceProvider.notifier).state = newValue;
//                       ref.invalidate(regenciesProvider);
//                     },
//                   ),
//                   SearchableDropdown(
//                     label: "Kabupaten/Kota *",
//                     isEnabled: _selectedProvince != null,
//                     itemsProvider: regenciesProvider,
//                     selectedValue: _selectedRegency,
//                     onChanged: (newValue) {
//                       setState(() {
//                         _selectedRegency = newValue;
//                         _selectedDistrict = null; _selectedVillage = null;
//                       });
//                       ref.read(selectedRegencyProvider.notifier).state = newValue;
//                       ref.invalidate(districtsProvider);
//                     },
//                   ),
//                   SearchableDropdown(
//                     label: "Kecamatan *",
//                     isEnabled: _selectedRegency != null,
//                     itemsProvider: districtsProvider,
//                     selectedValue: _selectedDistrict,
//                     onChanged: (newValue) {
//                       setState(() {
//                         _selectedDistrict = newValue;
//                         _selectedVillage = null;
//                       });
//                       ref.read(selectedDistrictProvider.notifier).state = newValue;
//                       ref.invalidate(villagesProvider);
//                     },
//                   ),
//                   SearchableDropdown(
//                     label: "Desa/Kelurahan *",
//                     isEnabled: _selectedDistrict != null,
//                     itemsProvider: villagesProvider,
//                     selectedValue: _selectedVillage,
//                     onChanged: (newValue) => setState(() => _selectedVillage = newValue),
//                   ),
//                   FormTextField(controller: _alamatC, label: 'Alamat', maxLines: 3),
//                   FormTextField(
//                     controller: _latLngC,
//                     label: 'Latlong',
//                     readOnly: true,
//                     onTap: _openMapDialog,
//                     suffixIcon: IconButton(
//                       icon: SvgPicture.asset(
//                         "assets/icons/location.svg",
//                         width: 24,
//                         height: 24,
//                         colorFilter: const ColorFilter.mode(
//                           AppColors.primaryColor,
//                           BlendMode.srcIn,
//                         ),
//                       ),
//                       onPressed: _openMapDialog,
//                     ),
//                   ),
//                   _buildMapPreview(),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               FormCardSection(
//                 title: "Data Store",
//                 iconAsset: "assets/icons/data_store.svg",
//                 children: [
//                   PopupButtonForm(
//                     label: 'Format Store',
//                     optionsProvider: formatStoreOptionsProvider,
//                     selectedValue: _selectedFormatStore,
//                     // PERBAIKAN: Ganti 'onChanged' menjadi 'onSelected'
//                     onSelected: (value) => setState(() => _selectedFormatStore = value),
//                   ),
//                   PopupButtonForm(
//                     label: 'Bentuk Objek',
//                     optionsProvider: bentukObjekOptionsProvider,
//                     selectedValue: _selectedBentukObjek,
//                     // PERBAIKAN: Ganti 'onChanged' menjadi 'onSelected'
//                     onSelected: (value) => setState(() => _selectedBentukObjek = value),
//                   ),
//                   FormTextField(controller: _alasHakC, label: 'Alas Hak'),
//                   FormTextField(controller: _jumlahLantaiC, label: 'Jumlah Lantai', keyboardType: TextInputType.number),
//                   FormTextField(controller: _lebarDepanC, label: 'Lebar Depan (m)', keyboardType: TextInputType.number),
//                   FormTextField(controller: _panjangC, label: 'Panjang (m)', keyboardType: TextInputType.number),
//                   FormTextField(controller: _luasC, label: 'Luas (m2)', keyboardType: TextInputType.number),
//                   FormTextField(controller: _hargaSewaC, label: 'Harga Sewa (+PPH 10%)', keyboardType: TextInputType.number),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               FormCardSection(
//                 title: "Data Pemilik",
//                 iconAsset: "assets/icons/avatar.svg",
//                 children: [
//                   FormTextField(controller: _namaPemilikC, label: 'Nama Pemilik'),
//                   FormTextField(controller: _kontakPemilikC, label: 'Kontak Pemilik'),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: editState.isLoading ? null : _onUpdate,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: editState.isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                         'Update',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       )
//                 ),
//               ),
//               const SizedBox(height: 24)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

