import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/kplt_form_detail_screen.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/kplt_form_screen.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/kplt_card.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/kplt_list_skeleton.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';

class AllKpltListPage extends ConsumerWidget {
  static const String route = '/all-kplt-list';
  final bool needInput;
  const AllKpltListPage({super.key, required this.needInput});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = needInput ? ref.watch(kpltNeedInputProvider) : ref.watch(kpltInProgressProvider);

    return Scaffold(
      appBar: CustomTopBar.general(
        title: needInput ? 'Perlu Input Anda' : 'Sedang Proses',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset("assets/icons/left_arrow.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: async.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Tidak ada data.'));
          }
          final ordered = List.of(list)
            ..sort((a, b) {
              final ta = a.tanggal;
              final tb = b.tanggal;
              return ta.compareTo(tb);
            });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: ordered.length,
            itemBuilder: (context, index) {
              final kpltItem = ordered[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    if (needInput) {
                      final ulokDataForForm = UsulanLokasi(
                        id: kpltItem.ulokId,
                        namaLokasi: kpltItem.namaLokasi,
                        alamat: kpltItem.alamat,
                        kecamatan: kpltItem.kecamatan,
                        desaKelurahan: kpltItem.desaKelurahan,
                        kabupaten: kpltItem.kabupaten,
                        provinsi: kpltItem.provinsi,
                        status: kpltItem.status,
                        tanggal: kpltItem.tanggal,
                        latLong: kpltItem.latLong,
                        formatStore: kpltItem.formatStore,
                        bentukObjek: kpltItem.bentukObjek,
                        alasHak: kpltItem.alasHak,
                        jumlahLantai: kpltItem.jumlahLantai,
                        lebarDepan: kpltItem.lebarDepan,
                        panjang: kpltItem.panjang,
                        luas: kpltItem.luas,
                        hargaSewa: kpltItem.hargaSewa,
                        namaPemilik: kpltItem.namaPemilik,
                        kontakPemilik: kpltItem.kontakPemilik,
                        formUlok: kpltItem.formUlok,
                        approvalIntip: kpltItem.approvalIntip,
                        tanggalApprovalIntip: kpltItem.tanggalApprovalIntip,
                        fileIntip: kpltItem.fileIntip,
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (_) => KpltFormPage(ulok: ulokDataForForm)));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => KpltDetailScreen(kpltId: kpltItem.id)));
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: KpltCard(kplt: kpltItem),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: KpltListSkeleton()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
