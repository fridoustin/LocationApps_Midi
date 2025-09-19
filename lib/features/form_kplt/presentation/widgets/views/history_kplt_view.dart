import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/kplt_card.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/kplt_list_skeleton.dart';
import 'package:midi_location/core/constants/color.dart';

class HistoryKpltView extends ConsumerWidget {
  const HistoryKpltView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(kpltHistoryProvider);

    return historyAsync.when(
      data: (kpltList) {
        if (kpltList.isEmpty) {
          return const Center(child: Text('Tidak ada data riwayat KPLT.'));
        }
        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async => ref.invalidate(kpltHistoryProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kpltList.length,
            itemBuilder: (context, index) {
              return KpltCard(kplt: kpltList[index]);
            },
          ),
        );
      },
      loading: () => const KpltListSkeleton(),
      error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
    );
  }
}