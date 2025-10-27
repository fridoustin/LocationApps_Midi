import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/main_layout.dart';
import 'package:midi_location/features/lokasi/presentation/pages/lokasi_mainscreen.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_form_page.dart';
import 'action_card.dart';
import 'skeletons/quick_actions_skeleton.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';

class QuickActionsSection extends ConsumerWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const QuickActionsSkeleton(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (profile) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: SvgPicture.asset(
                        'assets/icons/quick_action.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Quick Action',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  childAspectRatio: 1.6,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ActionCard(
                      title: 'Tambah Ulok',
                      iconPath: 'assets/icons/addulok.svg',
                      color: AppColors.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UlokFormPage(),
                          ),
                        );
                      },
                    ),
                    ActionCard(
                      title: 'Form KPLT',
                      iconPath: 'assets/icons/form_kplt.svg',
                      color: AppColors.cardOrange,
                      onTap: () {
                        ref.read(mainNavigationProvider.notifier).state = 1;
                        ref.read(lokasiMainTabProvider.notifier).state = 1;
                      },
                    ),
                    ActionCard(
                      title: 'Lihat Tugas',
                      iconPath: 'assets/icons/penugasan.svg',
                      color: AppColors.cardBlue,
                      onTap: () {
                        ref.read(mainNavigationProvider.notifier).state = 2;
                      },
                    ),
                    ActionCard(
                      title: 'Statistik',
                      iconPath: 'assets/icons/statistik.svg',
                      color: AppColors.successColor,
                      onTap: () {
                        ref.read(mainNavigationProvider.notifier).state = 3;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
