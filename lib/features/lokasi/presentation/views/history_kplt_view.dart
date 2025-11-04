import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/lokasi/presentation/pages/kplt_form_detail_screen.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/card_list_skeleton.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/kplt_card.dart';
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
              final kpltItem = kpltList[index];
              return InkWell(
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
              );
            },
          ),
        );
      },
      loading: () => const CommonListSkeleton(),
      error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
    );
  }
}