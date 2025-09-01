import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/SlidingTab/sliding_tab_bar_ulok.dart';
import 'package:midi_location/core/widgets/ulok_card.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_provider.dart';

class ULOKPage extends ConsumerStatefulWidget {
  const ULOKPage({super.key});
  static const String route = '/ulok';

  @override
  ConsumerState<ULOKPage> createState() => _ULOKPageState();
}

class _ULOKPageState extends ConsumerState<ULOKPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(ulokSearchQueryProvider);
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
      ref.read(ulokSearchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(ulokTabProvider);
    final ulokListAsync = ref.watch(ulokListProvider);

    return Column(
      children: [
        // WADAH BARU UNTUK TOMBOL TAB SESUAI REFERENSI
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SlidingTabBar(
            activeTab: activeTab,
            onTabChanged: (newTab) {
              ref.read(ulokSearchQueryProvider.notifier).state = '';
              _searchController.clear();
              ref.read(ulokTabProvider.notifier).state = newTab;
            },
          ),
        ),

        // Search Bar & Filter (UI Saja untuk sekarang)
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
                    hintText: 'Search Ulok',
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

        // Daftar Usulan Lokasi
        Expanded(
          child: ulokListAsync.when(
            data: (ulokList) {
              if (ulokList.isEmpty) {
                return const Center(child: Text('Tidak ada data ULok.'));
              }
              // RefreshIndicator untuk fitur pull-to-refresh
              return RefreshIndicator(
                color: AppColors.primaryColor,
                backgroundColor: AppColors.cardColor,
                onRefresh: () => ref.refresh(ulokListProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ulokList.length,
                  itemBuilder: (context, index) {
                    return UlokCard(ulok: ulokList[index]);
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