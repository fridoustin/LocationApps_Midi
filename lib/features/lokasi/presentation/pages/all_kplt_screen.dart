import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/lokasi/presentation/pages/kplt_form_detail_screen.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/card_list_skeleton.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/kplt_card.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/kplt_input_card.dart';

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
              final ta = a.createdAt;
              final tb = b.createdAt;
              return ta.compareTo(tb);
            });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: ordered.length,
            itemBuilder: (context, index) {
              final kpltItem = ordered[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: (needInput)
                    ? KpltNeedInputCard(kplt: kpltItem)
                    : InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => KpltDetailScreen(kpltId: kpltItem.id)));
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: KpltCard(kplt: kpltItem),
                      ),
              );
            },
          );
        },
        loading: () => const Center(child: CommonListSkeleton()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
