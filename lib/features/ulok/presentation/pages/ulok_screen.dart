import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/SlidingTab/sliding_tab_bar_ulok.dart';
import 'package:midi_location/features/ulok/presentation/pages/ulok_form_page.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_form_provider.dart';
import 'package:midi_location/features/ulok/presentation/widgets/draft_card.dart';
import 'package:midi_location/features/ulok/presentation/widgets/ulok_card.dart';
import 'package:midi_location/features/ulok/presentation/providers/ulok_provider.dart';
import 'package:midi_location/features/ulok/presentation/widgets/ulok_list_skeleton.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchController.text = ref.read(ulokSearchQueryProvider);
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
      ref.read(ulokSearchQueryProvider.notifier).state = query;
      ref.invalidate(ulokDraftsProvider);
      ref.invalidate(ulokListProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isShowingDrafts = ref.watch(showDraftsProvider);

    return Column(
      children: [
        // WADAH BARU UNTUK TOMBOL TAB SESUAI REFERENSI
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SlidingTabBar(
                  activeTab: ref.watch(ulokTabProvider),
                  onTabChanged: (newTab) {
                    // Jika sedang menampilkan draft, kembali ke mode normal
                    if (isShowingDrafts) {
                      ref.read(showDraftsProvider.notifier).state = false;
                    }
                    ref.read(ulokSearchQueryProvider.notifier).state = '';
                    _searchController.clear();
                    ref.read(ulokTabProvider.notifier).state = newTab;
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Toggle tampilan draft
                  ref.read(showDraftsProvider.notifier).update((state) => !state);
                },
                icon: const Icon(Icons.drafts_outlined),
                label: const Text('Drafts'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: isShowingDrafts ? AppColors.primaryColor : AppColors.cardColor,
                    foregroundColor: isShowingDrafts ? Colors.white : AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.primaryColor))),
              ),
            ],
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
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_alt),
              ),
            ],
          ),
        ),

        // Daftar Usulan Lokasi
        Expanded(
          child: isShowingDrafts
              ? _buildDraftsList() // Panggil method untuk menampilkan draft
              : _buildOnlineList(), // Panggil method untuk menampilkan data online
        ),
      ],
    );
  }
  Widget _buildOnlineList() {
    final ulokListAsync = ref.watch(ulokListProvider);
    return ulokListAsync.when(
      data: (ulokList) {
        if (ulokList.isEmpty) {
          return const Center(child: Text('Tidak ada data ULok.'));
        }
        return RefreshIndicator(
          color: AppColors.primaryColor,
          backgroundColor: AppColors.cardColor,
          onRefresh: () {
            ref.read(ulokSearchQueryProvider.notifier).state = '';
            _searchController.clear();
            return ref.refresh(ulokListProvider.future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ulokList.length,
            itemBuilder: (context, index) {
              return UlokCard(ulok: ulokList[index]);
            },
          ),
        );
      },
      loading: () => const UlokListSkeleton(),
      error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
    );
  }

  // Method helper untuk membangun list draft
  Widget _buildDraftsList() {
    final draftsAsync = ref.watch(ulokDraftsProvider);
    return draftsAsync.when(
      data: (draftList) {
        if (draftList.isEmpty) {
          return const Center(child: Text('Tidak ada data Draft.'));
        }
        return RefreshIndicator(
          color: AppColors.primaryColor,
          backgroundColor: AppColors.cardColor,
          onRefresh: () => ref.refresh(ulokDraftsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: draftList.length,
            itemBuilder: (context, index) {
              final draft = draftList[index];
              return UlokDraftCard(
                draft: draft,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UlokFormPage(draftData: draft),
                  ));
                },
              );
            },
          ),
        );
      },
      loading: () => const UlokListSkeleton(),
      error: (err, stack) => Center(child: Text('Gagal memuat draft: $err')),
    );
  }
}

