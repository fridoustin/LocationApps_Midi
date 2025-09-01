// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:midi_location/core/constants/color.dart';

class UlokFormPage extends StatefulWidget {
  const UlokFormPage({super.key});

  @override
  State<UlokFormPage> createState() => _UlokFormPageState();
}

class _UlokFormPageState extends State<UlokFormPage> {
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();

  String? selectedFormatStore;
  String? selectedBentukObjek;
  String selectedCountryCode = '+62';

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _tanggalUlokController = TextEditingController();
  final TextEditingController _latLongController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _latLongController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _tanggalUlokController.dispose();
    _latLongController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.textColor,
              surface: AppColors.backgroundColor,
              onSurface: AppColors.black,
            ),
            dialogBackgroundColor: AppColors.cardColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalUlokController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _openMapDialog() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Izin lokasi ditolak")));
      return;
    }

    LatLng? selectedLatLng = await showDialog<LatLng>(
      context: context,
      builder: (context) {
        LatLng tempLatLng = LatLng(0, 0);
        bool isLoading = true;
        final dialogMapController = MapController();

        Future<void> _getCurrentLocation(StateSetter setStateDialog) async {
          if (!context.mounted) return;
          setStateDialog(() {
            isLoading = true;
          });
          try {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            LatLng newLatLng = LatLng(position.latitude, position.longitude);

            if (context.mounted) {
              setStateDialog(() {
                tempLatLng = newLatLng;
                isLoading = false;
              });
              dialogMapController.move(newLatLng, 16);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Gagal mendapatkan lokasi: $e")),
              );
            }
          }
        }

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              if (isLoading) {
                _getCurrentLocation(setStateDialog);
              }

              return SizedBox(
                height: 400,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: FlutterMap(
                                    mapController: dialogMapController,
                                    options: MapOptions(
                                      initialCenter: tempLatLng,
                                      initialZoom: 16,
                                      onTap: (tapPosition, latLng) {
                                        setStateDialog(() {
                                          tempLatLng = latLng;
                                        });
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.midi.location',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: tempLatLng,
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
                                    ],
                                  ),
                                ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _getCurrentLocation(setStateDialog).then((_) {
                            Navigator.pop(context, tempLatLng);
                          });
                        },
                        icon: const Icon(Icons.my_location),
                        label: const Text("Gunakan Lokasi Saya Sekarang"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (selectedLatLng != null) {
      setState(() {
        _latLongController.text =
            "${selectedLatLng.latitude}, ${selectedLatLng.longitude}";
      });
    }
  }

  Widget _buildPhoneTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/indonesia.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text('+62', style: TextStyle(color: AppColors.black)),
                ],
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: 'Masukkan No Telp Pemilik',
                  hintStyle: TextStyle(color: AppColors.black.withOpacity(0.5)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    if (_latLongController.text.isEmpty) {
      return Container();
    }

    try {
      final parts = _latLongController.text.split(',');
      final lat = double.tryParse(parts[0].trim());
      final lon = double.tryParse(parts[1].trim());

      if (lat == null || lon == null) {
        return Container();
      }

      final previewLatLng = LatLng(lat, lon);

      return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 250,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: previewLatLng,
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
                      point: previewLatLng,
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
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return const Text(
        "Format Latlong tidak valid. Gunakan format 'latitude, longitude'.",
        style: TextStyle(color: AppColors.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 75, bottom: 40),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  "Form ULOK",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Positioned(
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      "assets/icons/left_arrow.svg",
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  child: SvgPicture.asset(
                    "assets/icons/notification.svg",
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildCardSection(
                      title: "Data Usulan Lokasi",
                      iconAsset: "assets/icons/location.svg",
                      iconColor: AppColors.primaryColor,
                      children: [
                        _buildTextField(
                          label: 'Nama ULOK *',
                          hint: 'Masukkan Nama Usulan Lokasi',
                        ),
                        _buildTextField(
                          label: 'Provinsi *',
                          hint: 'Masukkan Nama Provinsi',
                        ),
                        _buildTextField(
                          label: 'Kabupaten/Kota *',
                          hint: 'Masukkan Nama Kabupaten/Kota',
                        ),
                        _buildTextField(
                          label: 'Kecamatan *',
                          hint: 'Masukkan Nama Kecamatan',
                        ),
                        _buildTextField(
                          label: 'Kelurahan/Desa *',
                          hint: 'Masukkan Nama Kelurahan/Desa',
                        ),
                        _buildTextField(
                          label: 'Alamat *',
                          hint: 'Masukkan alamat usulan lokasi',
                        ),
                        _buildLatLongTextField(),
                        _buildMapPreview(),
                        _buildTextField(
                          label: 'Tanggal ULOK *',
                          hint: 'Pilih tanggal usulan lokasi',
                          iconAsset: 'assets/icons/calender.svg',
                          iconColor: AppColors.black,
                          controller: _tanggalUlokController,
                          onTap: () => _selectDate(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      title: "Data Store",
                      iconAsset: "assets/icons/data_store.svg",
                      iconColor: AppColors.primaryColor,
                      children: [
                        _buildPopupButton(
                          label: 'Format Store *',
                          items: ['Tipe 80', 'Tipe 100', 'Tipe 120'],
                          selectedValue: selectedFormatStore,
                          onSelected: (value) {
                            setState(() {
                              selectedFormatStore = value;
                            });
                          },
                        ),
                        _buildPopupButton(
                          label: 'Bentuk Objek *',
                          items: ['Ruko', 'Tanah Kosong'],
                          selectedValue: selectedBentukObjek,
                          onSelected: (value) {
                            setState(() {
                              selectedBentukObjek = value;
                            });
                          },
                        ),
                        _buildTextField(
                          label: 'Kabupaten/Kota *',
                          hint: 'Masukkan Nama Kabupaten/Kota',
                        ),
                        _buildTextField(
                          label: 'Alas Hak *',
                          hint: 'Masukkan alas hak',
                        ),
                        _buildTextField(
                          label: 'Jumlah Lantai',
                          hint: 'Masukkan jumlah lantai',
                        ),
                        _buildTextField(
                          label: 'Lebar Depan (m) *',
                          hint: 'Masukkan lebar depan',
                        ),
                        _buildTextField(
                          label: 'Panjang (m) *',
                          hint: 'Masukkan panjang tanah/bangunan',
                        ),
                        _buildTextField(
                          label: 'Luas (m2) *',
                          hint: 'Masukkan luas tanah/bangunan',
                        ),
                        _buildTextField(
                          label: 'Harga Sewa (+PPH 10%) *',
                          hint: 'Masukkan harga sewa',
                        ),
                        _buildTextField(
                          label: 'Kode ULOK GIS *',
                          hint: 'Masukkan kode ULOK GIS',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      title: "Data Pemilik",
                      iconAsset: "assets/icons/avatar.svg",
                      iconColor: AppColors.primaryColor,
                      children: [
                        _buildTextField(
                          label: 'Nama Pemilik *',
                          hint: 'Masukkan Nama Pemilik',
                        ),
                        const SizedBox(height: 15),
                        _buildLabel('Kontak Pemilik *'),
                        _buildPhoneTextField(),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cardColor,
                              foregroundColor: AppColors.primaryColor,
                              side: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Simpan Draft'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.textColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required String iconAsset,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(title, iconAsset, iconColor: iconColor),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String iconAsset, {
    Color? iconColor,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          iconAsset,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            iconColor ?? AppColors.black,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    if (label.contains("*")) {
      final parts = label.split("*");
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.black, fontSize: 14),
          children: [
            TextSpan(text: parts[0].trimRight() + " "),
            const TextSpan(
              text: "*",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return Text(label, style: const TextStyle(color: AppColors.black));
  }

  Widget _buildLatLongTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('Latlong *'),
              if (_latLongController.text.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _latLongController.clear();
                    });
                  },
                  child: const Text(
                    "Hapus",
                    style: TextStyle(
                      color: AppColors.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _latLongController,
              style: const TextStyle(color: AppColors.black),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'Cari alamat pada peta atau isi manual',
                hintStyle: TextStyle(color: AppColors.black.withOpacity(0.5)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                suffixIcon: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/location.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: _openMapDialog,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? iconAsset,
    Color? iconColor,
    VoidCallback? onTap,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: controller,
              readOnly: onTap != null,
              style: const TextStyle(color: AppColors.black),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.black.withOpacity(0.5)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                suffixIcon:
                    iconAsset != null
                        ? GestureDetector(
                          onTap: onTap,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              iconAsset,
                              width: 24,
                              height: 24,
                              colorFilter:
                                  iconColor != null
                                      ? ColorFilter.mode(
                                        iconColor,
                                        BlendMode.srcIn,
                                      )
                                      : null,
                            ),
                          ),
                        )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupButton({
    required String label,
    required List<String> items,
    String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      selectedValue ?? 'Pilih opsi',
                      style: TextStyle(
                        color:
                            selectedValue == null
                                ? AppColors.black.withOpacity(0.5)
                                : AppColors.black,
                      ),
                    ),
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: const PopupMenuThemeData(
                      color: AppColors.cardColor,
                      textStyle: TextStyle(color: AppColors.black),
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    icon: SvgPicture.asset(
                      "assets/icons/down_arrow.svg",
                      width: 8,
                      height: 8,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                    onSelected: onSelected,
                    itemBuilder: (BuildContext context) {
                      return items.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
