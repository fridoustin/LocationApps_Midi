import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_form_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/form_helpers.dart';
import 'package:midi_location/features/ulok/domain/entities/usulan_lokasi.dart';
import 'package:midi_location/features/ulok/presentation/widgets/helpers/info_row.dart';
import 'package:midi_location/features/ulok/presentation/widgets/helpers/two_column_row.dart';
import 'package:midi_location/features/ulok/presentation/widgets/map_detail.dart';
import 'package:midi_location/features/ulok/presentation/widgets/ulok_detail_section.dart';

class KpltFormPage extends ConsumerStatefulWidget {
  final UsulanLokasi ulok;
  const KpltFormPage({super.key, required this.ulok});
  static const String route = '/kplt/form';

  @override
  ConsumerState<KpltFormPage> createState() => _KpltFormPageState();
}

class _KpltFormPageState extends ConsumerState<KpltFormPage> {
  final _skorFplController = TextEditingController();
  final _stdController = TextEditingController();
  final _apcController = TextEditingController();
  final _spdController = TextEditingController();
  final _peRabController = TextEditingController();

  @override
  void dispose() {
    _skorFplController.dispose();
    _stdController.dispose();
    _apcController.dispose();
    _spdController.dispose();
    _peRabController.dispose();
    super.dispose();
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
      widget.ulok.desa_kelurahan,
      widget.ulok.kecamatan.isNotEmpty ? 'Kec. ${widget.ulok.kecamatan}' : '',
      widget.ulok.kabupaten,
      widget.ulok.provinsi,
    ].where((e) => e.isNotEmpty).join(', ');

    // Mengakses provider form
    final formProvider = kpltFormProvider(widget.ulok.id);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    // Listener untuk menampilkan Snackbar dan navigasi
    ref.listen(formProvider, (previous, next) {
      if (next.status == KpltFormStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Data KPLT berhasil disimpan!'),
            backgroundColor: AppColors.successColor));
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      } else if (next.status == KpltFormStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${next.errorMessage}'),
            backgroundColor: AppColors.primaryColor));
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.ulok.namaLokasi,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [
                      SvgPicture.asset("assets/icons/time.svg",
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                              Colors.grey, BlendMode.srcIn)),
                      const SizedBox(width: 4),
                      Text("Approved on $formattedDate",
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12))
                    ])
                  ]),
            ),
            const SizedBox(height: 16),
            DetailSectionWidget(
                title: "Data Usulan Lokasi",
                iconPath: "assets/icons/location.svg",
                children: [
                  InfoRowWidget(label: "Alamat", value: fullAddress),
                  InfoRowWidget(
                      label: "LatLong", value: widget.ulok.latLong ?? "-"),
                  const SizedBox(height: 12),
                  InteractiveMapWidget(position: latLng)
                ]),
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
                    value2: widget.ulok.jumlahLantai?.toString() ?? '-'
                  ),
                  TwoColumnRowWidget(
                    label1: "Lebar Depan (m)",
                    value1: "${widget.ulok.lebarDepan ?? '-'}",
                    label2: "Panjang (m)",
                    value2: "${widget.ulok.panjang ?? '-'}"
                  ),
                  TwoColumnRowWidget(
                    label1: "Luas (m2)",
                    value1: "${widget.ulok.luas ?? '-'}",
                    label2: "Harga Sewa",
                    value2: widget.ulok.hargaSewa != null
                        ? NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(widget.ulok.hargaSewa)
                        : '-'
                  ),
                ]),
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
            const Divider(thickness: 1, height: 32),
            DetailSectionWidget(
                title: "Analisa & FPL",
                iconPath: "assets/icons/analytics.svg", // Ganti dengan ikon yang sesuai
                children: [
                  CustomDropdownFormField(
                      label: "Karakter Lokasi",
                      items: const ['Padat', 'Sedang', 'Sepi'], // Contoh
                      value: formState.karakterLokasi,
                      onChanged: (value) =>
                          formNotifier.onKarakterLokasiChanged(value!)),
                  CustomDropdownFormField(
                      label: "Sosial Ekonomi",
                      items: const ['A', 'B', 'C'], // Contoh
                      value: formState.sosialEkonomi,
                      onChanged: (value) =>
                          formNotifier.onSosialEkonomiChanged(value!)),
                  CustomNumberTextFormField(
                      controller: _skorFplController,
                      label: "Skor FPL",
                      onChanged: (value) =>
                          formNotifier.onSkorFplChanged(value)),
                  CustomNumberTextFormField(
                      controller: _stdController,
                      label: "STD",
                      onChanged: (value) => 
                          formNotifier.onStdChanged(value)),
                  CustomNumberTextFormField(
                      controller: _apcController,
                      label: "APC",
                      onChanged: (value) => 
                          formNotifier.onApcChanged(value)),
                  CustomNumberTextFormField(
                      controller: _spdController,
                      label: "SPD",
                      onChanged: (value) =>
                          formNotifier.onSpdChanged(value))
                ]),
            const SizedBox(height: 16),
            DetailSectionWidget(
                title: "Data PE",
                iconPath: "assets/icons/data_store.svg", // Ganti dengan ikon yang sesuai
                children: [
                  CustomDropdownFormField(
                      label: "PE Status",
                      items: const ['Layak', 'Tidak Layak'], // Contoh
                      value: formState.peStatus,
                      onChanged: (value) =>
                          formNotifier.onPeStatusChanged(value!)),
                  CustomNumberTextFormField(
                      controller: _peRabController,
                      label: "PE RAB",
                      onChanged: (value) =>
                          formNotifier.onPeRabChanged(value))
                ]),
            const SizedBox(height: 16),
            DetailSectionWidget(
                title: "Upload Dokumen",
                iconPath: "assets/icons/upload.svg", // Ganti dengan ikon yang sesuai
                children: [
                  FileUploadWidget(
                      label: "PDF Foto",
                      fileName: formState.pdfFoto?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'pdfFoto')),
                  FileUploadWidget(
                      label: "Counting Kompetitor",
                      fileName: formState.countingKompetitor?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'countingKompetitor')),
                  FileUploadWidget(
                      label: "PDF Pembanding",
                      fileName: formState.pdfPembanding?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'pdfPembanding')),
                  FileUploadWidget(
                      label: "PDF KKS",
                      fileName: formState.pdfKks?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'pdfKks')),
                  FileUploadWidget(
                      label: "Excel FPL",
                      fileName: formState.excelFpl?.path.split('/').last,
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'excelFpl')),
                  FileUploadWidget(
                      label: "Excel PE",
                      fileName: formState.excelPe?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'excelPe')),
                  FileUploadWidget(
                      label: "PDF Form Ukur",
                      fileName: formState.pdfFormUkur?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'pdfFormUkur')),
                  FileUploadWidget(
                      label: "Video Traffic Siang",
                      fileName: formState.videoTrafficSiang?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'videoTrafficSiang')),
                  FileUploadWidget(
                      label: "Video Traffic Malam",
                      fileName: formState.videoTrafficMalam?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'videoTrafficMalam')),
                  FileUploadWidget(
                      label: "Video 360 Siang",
                      fileName: formState.video360Siang?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'video360Siang')),
                  FileUploadWidget(
                      label: "Video 360 Malam",
                      fileName: formState.video360Malam?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'video360Malam')),
                  FileUploadWidget(
                      label: "Peta Coverage",
                      fileName: formState.petaCoverage?.path.split('/').last, 
                      onTap: () =>
                          pickFile(formNotifier.onFilePicked, 'petaCoverage'))
                ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: formState.status == KpltFormStatus.loading
                    ? null
                    : () => formNotifier.submitForm(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: formState.status == KpltFormStatus.loading
                    ? const CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.white)
                    : const Text("Simpan Data KPLT",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}