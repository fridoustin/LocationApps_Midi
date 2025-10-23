import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/domain/entities/kplt_filter.dart';
import 'package:midi_location/features/lokasi/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/kplt_filter_dialog.dart';
import 'package:midi_location/features/lokasi/presentation/views/history_kplt_view.dart';
import 'package:midi_location/features/lokasi/presentation/views/recent_kplt_view.dart';

// Provider untuk tab KPLT (Recent, History)
final kpltSubTabProvider = StateProvider<int>((ref) => 0);

class KpltView extends ConsumerStatefulWidget {
  const KpltView({super.key});

  @override
  ConsumerState<KpltView> createState() => _KpltViewState();
}

class _KpltViewState extends ConsumerState<KpltView>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchController.text = ref.read(kpltSearchQueryProvider);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(kpltSearchQueryProvider.notifier).state = query;
    });
  }

  void _onSubTabChanged(int index) {
    ref.read(kpltSubTabProvider.notifier).state = index;
    ref.read(kpltSearchQueryProvider.notifier).state = '';
    _searchController.clear();
  }

  int _computeFilterBadgeCount(KpltFilter filter) {
    int c = 0;
    if (filter.status != null) c++;
    if (filter.year != null) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentFilter = ref.watch(kpltFilterProvider);
    final badgeCount = _computeFilterBadgeCount(currentFilter);
    final currentSubTab = ref.watch(kpltSubTabProvider);

    return Column(
      children: [
        // Sub-tabs (Recent, History)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _buildSubTabBar(currentSubTab),
        ),

        // Search Bar & Filter
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
                    ref.invalidate(kpltNeedInputProvider);
                    ref.invalidate(kpltInProgressProvider);
                    ref.invalidate(kpltHistoryProvider);
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
                      child: const Center(
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

        // Content
        Expanded(
          child: _buildContent(currentSubTab),
        ),
      ],
    );
  }

  Widget _buildSubTabBar(int currentIndex) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 2;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  left: currentIndex * tabWidth,
                  child: Container(
                    width: tabWidth,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildSubTab('Recent', 0, tabWidth, currentIndex),
                    _buildSubTab('History', 1, tabWidth, currentIndex),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubTab(String label, int index, double width, int currentIndex) {
    final isActive = currentIndex == index;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => _onSubTabChanged(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.white : AppColors.black,
              ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(int currentTab) {
    switch (currentTab) {
      case 0:
        return const RecentKpltView();
      case 1:
        return const HistoryKpltView();
      default:
        return const RecentKpltView();
    }
  }
}