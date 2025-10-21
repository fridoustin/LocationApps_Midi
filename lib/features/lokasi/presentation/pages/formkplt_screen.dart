import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/SlidingTab/sliding_tab_bar_kplt.dart';
import 'package:midi_location/features/lokasi/domain/entities/kplt_filter.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/kplt_filter_dialog.dart';
import 'package:midi_location/features/lokasi/presentation/views/history_kplt_view.dart';
import 'package:midi_location/features/lokasi/presentation/views/recent_kplt_view.dart';

class FormKPLTPage extends ConsumerStatefulWidget {
  const FormKPLTPage({super.key});
  static const String route = '/formkplt';

  @override
  ConsumerState<FormKPLTPage> createState() => _KPLTPageState();
}

class _KPLTPageState extends ConsumerState<FormKPLTPage> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  Timer? _debounce;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.text = ref.read(kpltSearchQueryProvider);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(kpltSearchQueryProvider.notifier).state = '';
        _searchController.clear();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose(); 
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(kpltSearchQueryProvider.notifier).state = query;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(kpltFilterProvider);
    // ignore: no_leading_underscores_for_local_identifiers
    int _computeFilterBadgeCount(KpltFilter filter) {
      int c = 0;
      if (filter.status != null) c++;
      if (filter.year != null) c++;
      return c;
    }
    final badgeCount = _computeFilterBadgeCount(currentFilter);
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SlidingTabBarKplt(
              controller: _tabController,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  cursorColor: AppColors.black,
                  decoration: const InputDecoration(
                    hintText: 'Search Form KPLT',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              GestureDetector(
                onTap: () async {
                  final current = ref.read(kpltFilterProvider);
                  final newFilter = await showModalBottomSheet<KpltFilter>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => KpltFilterDialog(initialFilter: current),
                  );

                  if (newFilter != null) {
                    ref.read(kpltFilterProvider.notifier).state = newFilter;
                    // invalidate providers to refresh lists
                    ref.invalidate(kpltNeedInputProvider);
                    ref.invalidate(kpltInProgressProvider);
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 50,
                      width: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,               
                        borderRadius: BorderRadius.circular(12),  
                        border: Border.all(color: Colors.grey),   
                      ),
                      child: Center(
                        child: Icon(Icons.filter_list_alt, color: AppColors.primaryColor),
                      ),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -4,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 18),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              badgeCount > 99 ? '99+' : badgeCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
            // Gunakan TabBarView untuk menampilkan konten sesuai tab
            child: TabBarView(
              controller: _tabController,
              children: const [
                RecentKpltView(),
                HistoryKpltView(),
              ],
            ),
          ),
        ],
    );
  }
}