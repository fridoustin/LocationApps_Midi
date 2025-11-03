import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/widgets/lokasi_top_tab_bar.dart';
import 'package:midi_location/features/lokasi/presentation/views/progress_kplt_view.dart';
import 'package:midi_location/features/lokasi/presentation/views/usulan_lokasi_view.dart';
import 'package:midi_location/features/lokasi/presentation/views/kplt_view.dart';
// import 'package:midi_location/features/lokasi/presentation/views/perpanjangan_view.dart';

// Provider untuk mengelola tab aktif di level utama
final lokasiMainTabProvider = StateProvider<int>((ref) => 0);

class LokasiMainPage extends ConsumerWidget {
  const LokasiMainPage({super.key});
  static const String route = '/lokasi';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(lokasiMainTabProvider);

    return Column(
      children: [
        // Top-level Tab Bar (Usulan Lokasi, KPLT, Perpanjangan)
        LokasiTopTabBar(
          currentIndex: currentTab,
          onTabChanged: (index) {
            ref.read(lokasiMainTabProvider.notifier).state = index;
          },
        ),
        
        // Content untuk setiap tab
        Expanded(
          child: IndexedStack(
            index: currentTab,
            children: const [
              UsulanLokasiView(),
              KpltView(),
              ProgressKpltView()
              // PerpanjanganView(),
            ],
          ),
        ),
      ],
    );
  }
}