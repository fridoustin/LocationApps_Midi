import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/all_kplt_screen.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/kplt_form_detail_screen.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/kplt_form_screen.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/kplt_card.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/kplt_list_skeleton.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/section_header.dart';
import 'package:midi_location/features/lokasi/domain/entities/usulan_lokasi.dart';

class RecentKpltView extends ConsumerWidget {
  const RecentKpltView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needInputAsync = ref.watch(kpltNeedInputProvider);
    final inProgressAsync = ref.watch(kpltInProgressProvider);

    return RefreshIndicator(
      color: AppColors.primaryColor,
      backgroundColor: Colors.white,
      onRefresh: () async {
        ref.invalidate(kpltNeedInputProvider);
        ref.invalidate(kpltInProgressProvider);
      },
      child: CustomScrollView(
        slivers: [
          // --- SEKSI PERLU INPUT ---
          needInputAsync.when(
            data: (list) {
              final ordered = List.of(list);
              ordered.sort((a, b) {
                final ta = a.tanggal;
                final tb = b.tanggal;
                return ta.compareTo(tb);
              });
              final displayed = ordered.take(4).toList();

              return SliverMainAxisGroup(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Perlu Input Anda',
                        count: list.length,
                        icon: Icons.edit_note,
                        iconColor: Colors.orange.shade700,
                        onShowAll: list.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).pushNamed(
                                  AllKpltListPage.route,
                                  arguments: {'needInput': true},
                                );
                              },
                      ),
                    ),
                  ),
                  if (list.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Center(
                            child: Text('Tidak ada tugas baru.',
                                style: TextStyle(color: Colors.grey))),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final kpltItem = displayed[index];
                          return GestureDetector(
                            onTap: () {
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
                                  fileIntip: kpltItem.fileIntip
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KpltFormPage(ulok: ulokDataForForm),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: KpltCard(kplt: kpltItem),
                            ),
                          );
                        },
                        childCount: displayed.length,
                      ),
                    ),
                ],
              );
            },
            loading: () => const SliverToBoxAdapter(child: KpltListSkeleton()),
            error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),

          // --- SEKSI SEDANG PROSES ---
          inProgressAsync.when(
            data: (list) {
              final ordered = List.of(list);
              ordered.sort((a, b) {
                final ta = a.tanggal;
                final tb = b.tanggal;
                return ta.compareTo(tb);
              });
              final displayed = ordered.take(4).toList();

              return SliverMainAxisGroup(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Sedang Proses',
                        count: list.length,
                        icon: Icons.hourglass_top_rounded,
                        iconColor: Colors.blue.shade700,
                        onShowAll: list.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).pushNamed(
                                  AllKpltListPage.route,
                                  arguments: {'needInput': false},
                                );
                              },
                      ),
                    ),
                  ),
                  if (list.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Center(
                            child: Text('Tidak ada KPLT yang sedang diproses.',
                                style: TextStyle(color: Colors.grey))),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final kpltItem = displayed[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KpltDetailScreen(kpltId: kpltItem.id),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: KpltCard(kplt: kpltItem),
                            ),
                          );
                        },
                        childCount: displayed.length,
                      ),
                    ),
                ],
              );
            },
            loading: () => const SliverToBoxAdapter(child: KpltListSkeleton()),
            error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
    );
  }
}