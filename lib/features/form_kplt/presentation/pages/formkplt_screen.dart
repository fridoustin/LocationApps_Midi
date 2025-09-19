import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/SlidingTab/sliding_tab_bar_kplt.dart';
import 'package:midi_location/features/form_kplt/presentation/providers/kplt_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/views/history_kplt_view.dart';
import 'package:midi_location/features/form_kplt/presentation/widgets/views/recent_kplt_view.dart';

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
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list_alt)),
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