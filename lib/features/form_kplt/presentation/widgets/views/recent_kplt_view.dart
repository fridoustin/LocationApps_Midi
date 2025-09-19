import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/kplt_card.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/kplt_list_skeleton.dart';
import 'package:midi_location/core/constants/color.dart';

class RecentKpltView extends ConsumerWidget {
  const RecentKpltView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needInputAsync = ref.watch(kpltNeedInputProvider);
    final inProgressAsync = ref.watch(kpltInProgressProvider);

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () async {
        ref.invalidate(kpltNeedInputProvider);
        ref.invalidate(kpltInProgressProvider);
      },
      child: CustomScrollView(
        slivers: [
          needInputAsync.when(
            data: (list) => SliverMainAxisGroup(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Perlu Input Anda',
                      count: list.length,
                      icon: Icons.edit_note,
                      iconColor: Colors.orange.shade700,
                    ),
                  ),
                ),
                if (list.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Center(child: Text('Tidak ada tugas baru.', style: TextStyle(color: Colors.grey))),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: KpltCard(kplt: list[index]),
                      ),
                      childCount: list.length,
                    ),
                  ),
              ],
            ),
            loading: () => const SliverToBoxAdapter(child: KpltListSkeleton()),
            error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
          
          // --- SEKSI SEDANG PROSES ---
          inProgressAsync.when(
            data: (list) => SliverMainAxisGroup(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 8), // Padding atas diubah menjadi 32
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Sedang Proses',
                      count: list.length,
                      icon: Icons.hourglass_top_rounded,
                      iconColor: Colors.blue.shade700,
                    ),
                  ),
                ),
                if (list.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Center(child: Text('Tidak ada KPLT yang sedang diproses.', style: TextStyle(color: Colors.grey))),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: KpltCard(kplt: list[index]),
                      ),
                      childCount: list.length,
                    ),
                  ),
              ],
            ),
            loading: () => const SliverToBoxAdapter(child: KpltListSkeleton()),
            error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color iconColor;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded( // <-- TAMBAHAN: Agar judul mendorong counter ke kanan
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
        ),
        // Spacer dihapus agar tidak terlalu ke kanan
        if (count > 0)
          // DIGANTI: Dari Chip menjadi Container agar berbentuk persegi
          Container(
            width: 24, // Lebar dan tinggi sama untuk membuatnya persegi
            height: 24,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(6), // Sudut membulat
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}