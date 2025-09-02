import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/SlidingTab/sliding_tab_bar_kplt.dart';
import 'package:midi_location/core/widgets/kplt_card.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';

class FormKPLTPage extends ConsumerStatefulWidget {
  const FormKPLTPage({super.key});
  static const String route = '/formkplt';

  @override
  ConsumerState<FormKPLTPage> createState() => _KPLTPageState();
}

class _KPLTPageState extends ConsumerState<FormKPLTPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(kpltSearchQueryProvider);
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
  
  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(kpltTabProvider);
    final kpltListAsync = ref.watch(kpltListProvider);

    return Column(
        children: [
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SlidingTabBarKplt(
            activeTab: activeTab,
            onTabChanged: (newTab) {
              ref.read(kpltSearchQueryProvider.notifier).state = '';
              _searchController.clear();
              ref.read(kpltTabProvider.notifier).state = newTab;
            },
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
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list_alt)),
            ],
          ),
        ),

        Expanded(
          child: kpltListAsync.when(
            data: (kpltList) {
              if (kpltList.isEmpty) {
                return const Center(child: Text('Tidak ada data KPLT.'));
              }
              // RefreshIndicator untuk fitur pull-to-refresh
              return RefreshIndicator(
                color: AppColors.primaryColor,
                backgroundColor: AppColors.cardColor,
                onRefresh: () => ref.refresh(kpltListProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kpltList.length,
                  itemBuilder: (context, index) {
                    return KpltCard(kplt: kpltList[index]);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
            error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
          ),
        ),
      ],
    );
  }
}