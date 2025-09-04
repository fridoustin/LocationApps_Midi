import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class InteractiveMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  const InteractiveMapWidget({super.key, required this.initialPosition});

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: widget.initialPosition,
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: widget.initialPosition,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UlokEditPage extends StatefulWidget {
  final UsulanLokasi ulok;
  const UlokEditPage({super.key, required this.ulok});

  @override
  State<UlokEditPage> createState() => _UlokEditPageState();
}

class _UlokEditPageState extends State<UlokEditPage> {
  late TextEditingController _latLongController;
  late TextEditingController _namaUlokController;
  late TextEditingController _provinsiController;
  late TextEditingController _kabupatenController;
  late TextEditingController _kecamatanController;
  late TextEditingController _kelurahanController;
  late TextEditingController _alamatController;
  late TextEditingController _formatStoreController;
  late TextEditingController _bentukObjekController;
  late TextEditingController _alasHakController;
  late TextEditingController _jumlahLantaiController;
  late TextEditingController _lebarDepanController;
  late TextEditingController _panjangController;
  late TextEditingController _luasController;
  late TextEditingController _hargaSewaController;
  late TextEditingController _namaPemilikController;
  late TextEditingController _kontakPemilikController;

  @override
  void initState() {
    super.initState();
    _namaUlokController = TextEditingController(text: widget.ulok.namaLokasi);
    _provinsiController = TextEditingController(text: widget.ulok.provinsi);
    _kabupatenController = TextEditingController(text: widget.ulok.kabupaten);
    _kecamatanController = TextEditingController(text: widget.ulok.kecamatan);
    _kelurahanController = TextEditingController(
      text: widget.ulok.desa_kelurahan,
    );
    _alamatController = TextEditingController(text: widget.ulok.alamat);
    _latLongController = TextEditingController(text: widget.ulok.latLong ?? "");
    _formatStoreController = TextEditingController(
      text: widget.ulok.formatStore,
    );
    _bentukObjekController = TextEditingController(
      text: widget.ulok.bentukObjek,
    );
    _alasHakController = TextEditingController(text: widget.ulok.alasHak);
    _jumlahLantaiController = TextEditingController(
      text: widget.ulok.jumlahLantai?.toString(),
    );
    _lebarDepanController = TextEditingController(
      text: widget.ulok.lebarDepan?.toString(),
    );
    _panjangController = TextEditingController(
      text: widget.ulok.panjang?.toString(),
    );
    _luasController = TextEditingController(text: widget.ulok.luas?.toString());
    _hargaSewaController = TextEditingController(
      text:
          widget.ulok.hargaSewa != null
              ? NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp. ',
                decimalDigits: 0,
              ).format(widget.ulok.hargaSewa)
              : "",
    );
    _namaPemilikController = TextEditingController(
      text: widget.ulok.namaPemilik,
    );
    _kontakPemilikController = TextEditingController(
      text: widget.ulok.kontakPemilik,
    );
  }

  @override
  void dispose() {
    _namaUlokController.dispose();
    _provinsiController.dispose();
    _kabupatenController.dispose();
    _kecamatanController.dispose();
    _kelurahanController.dispose();
    _alamatController.dispose();
    _latLongController.dispose();
    _formatStoreController.dispose();
    _bentukObjekController.dispose();
    _alasHakController.dispose();
    _jumlahLantaiController.dispose();
    _lebarDepanController.dispose();
    _panjangController.dispose();
    _luasController.dispose();
    _hargaSewaController.dispose();
    _namaPemilikController.dispose();
    _kontakPemilikController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGenericTextField(
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: _buildLabel(label),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
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
              _buildLabel('LatLong *'),
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

  void _openMapDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Peta Lokasi"),
          content: const Text("Fungsionalitas peta belum diimplementasikan."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String latLongString =
        _latLongController.text.isNotEmpty ? _latLongController.text : "0,0";
    final latLng = LatLng(
      double.tryParse(latLongString.split(',')[0]) ?? 0,
      double.tryParse(latLongString.split(',')[1]) ?? 0,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Form ULOK',
        showNotificationButton: true,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              title: "Data Usulan Lokasi",
              iconPath: "assets/icons/location.svg",
              children: [
                _buildGenericTextField("Nama ULOK", _namaUlokController),
                _buildGenericTextField("Provinsi", _provinsiController),
                _buildGenericTextField("Kabupaten/Kota", _kabupatenController),
                _buildGenericTextField("Kecamatan", _kecamatanController),
                _buildGenericTextField("Kelurahan/Desa", _kelurahanController),
                _buildGenericTextField("Alamat", _alamatController),
                _buildLatLongTextField(),
                const SizedBox(height: 12),
                InteractiveMapWidget(initialPosition: latLng),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: "Data Store",
              iconPath: "assets/icons/data_store.svg",
              children: [
                _buildGenericTextField("Format Store", _formatStoreController),
                _buildGenericTextField("Bentuk Objek", _bentukObjekController),
                _buildGenericTextField("Alas Hak", _alasHakController),
                _buildGenericTextField(
                  "Jumlah Lantai",
                  _jumlahLantaiController,
                ),
                _buildGenericTextField(
                  "Lebar Depan (m)",
                  _lebarDepanController,
                ),
                _buildGenericTextField("Panjang (m)", _panjangController),
                _buildGenericTextField("Luas (m2)", _luasController),
                _buildGenericTextField("Harga Sewa", _hargaSewaController),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: "Data Pemilik",
              iconPath: "assets/icons/profile.svg",
              children: [
                _buildGenericTextField("Nama Pemilik", _namaPemilikController),
                _buildGenericTextField(
                  "Kontak Pemilik",
                  _kontakPemilikController,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String iconPath,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}
