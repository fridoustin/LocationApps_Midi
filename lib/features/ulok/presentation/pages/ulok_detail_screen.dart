import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/ulok/presentation/pages/ulok_edit_page.dart'
    show UlokEditPage;
import 'package:midi_location/features/ulok/presentation/pages/ulok_form_page.dart';

class InteractiveMapWidget extends StatefulWidget {
  final LatLng initialPosition;

  const InteractiveMapWidget({Key? key, required this.initialPosition})
    : super(key: key);

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  late Future<Position> _futurePosition;

  @override
  void initState() {
    super.initState();
    _futurePosition = _determinePosition();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi dinonaktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Izin lokasi ditolak secara permanen, kami tidak dapat meminta izin.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

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

class UlokDetailPage extends StatelessWidget {
  final UsulanLokasi ulok;
  const UlokDetailPage({super.key, required this.ulok});
  static const String route = '/ulok/detail';

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return const Color(0xFFFFC107);
      case 'OK':
        return Colors.green;
      case 'NOK':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("dd MMMM yyyy").format(ulok.tanggal);
    final String latLongString = ulok.latLong ?? "0,0";

    final latLng = LatLng(
      double.tryParse(latLongString.split(',')[0]) ?? 0,
      double.tryParse(latLongString.split(',')[1]) ?? 0,
    );

    final fullAddress = [
      ulok.alamat,
      ulok.desa_kelurahan,
      ulok.kecamatan,
      ulok.kabupaten,
      ulok.provinsi,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'ULOK Detail',
        showNotificationButton: false,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
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
                            Expanded(
                              child: Text(
                                ulok.namaLokasi,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(ulok.status),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ulok.status,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Dibuat Pada $formattedDate",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    title: "Data Usulan Lokasi",
                    iconPath: "assets/icons/location.svg",
                    children: [
                      _buildInfoRow("Alamat", fullAddress),
                      _buildInfoRow("LatLong", ulok.latLong ?? "-"),
                      const SizedBox(height: 12),
                      InteractiveMapWidget(initialPosition: latLng),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    title: "Data Store",
                    iconPath: "assets/icons/data_store.svg",
                    children: [
                      _buildTwoColumnRow(
                        "Format Store",
                        ulok.formatStore ?? '-',
                        "Bentuk Objek",
                        ulok.bentukObjek ?? '-',
                      ),
                      _buildTwoColumnRow(
                        "Alas Hak",
                        ulok.alasHak ?? '-',
                        "Jumlah Lantai",
                        ulok.jumlahLantai?.toString() ?? '-',
                      ),
                      _buildTwoColumnRow(
                        "Lebar Depan (m)",
                        "${ulok.lebarDepan ?? '-'} m",
                        "Panjang (m)",
                        "${ulok.panjang ?? '-'} m",
                      ),
                      _buildTwoColumnRow(
                        "Luas (m2)",
                        "${ulok.luas ?? '-'} m2",
                        "Harga Sewa",
                        ulok.hargaSewa != null
                            ? NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp. ',
                              decimalDigits: 0,
                            ).format(ulok.hargaSewa)
                            : '-',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    title: "Data Pemilik",
                    iconPath: "assets/icons/profile.svg",
                    children: [
                      _buildTwoColumnRow(
                        "Nama Pemilik",
                        ulok.namaPemilik ?? '-',
                        "Kontak Pemilik",
                        ulok.kontakPemilik ?? '-',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UlokEditPage(ulok: ulok),
                            ),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Edit Data Ulok",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          const Divider(thickness: 1, height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label :",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTwoColumnRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$label1 :",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  value1,
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$label2 :",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  value2,
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
