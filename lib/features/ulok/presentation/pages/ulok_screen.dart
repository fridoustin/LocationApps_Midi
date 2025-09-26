import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/SlidingTab/sliding_tab_bar_ulok.dart';
import 'package:midi_location/features/ulok/domain/entities/ulok_form_state.dart';
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SlidingTabBar(
                  activeTab: ref.watch(ulokTabProvider),
                  onTabChanged: (newTab) {
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
                  ref.read(showDraftsProvider.notifier).update((state) => !state);
                },
                icon: const Icon(Icons.drafts_outlined),
                label: const Text('Drafts'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    backgroundColor: isShowingDrafts ? AppColors.primaryColor : AppColors.cardColor,
                    foregroundColor: isShowingDrafts ? Colors.white : AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.primaryColor))),
              ),
            ],
          ),
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
              ? _buildDraftsList()
              : _buildOnlineList(),
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
          onRefresh: () => ref.refresh(ulokListProvider.future),
          color: AppColors.primaryColor,
          backgroundColor: AppColors.cardColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ulokList.length,
            itemBuilder: (context, index) {
              final ulok = ulokList[index];
              return GestureDetector(
                onTap: () {
                  final initialState = UlokFormState.fromUsulanLokasi(ulok);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UlokFormPage(initialState: initialState),
                  ));
                },
                child: UlokCard(ulok: ulok),
              );
            },
          ),
        );
      },
      loading: () => const UlokListSkeleton(),
      error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
    );
  }

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
                    builder: (context) => UlokFormPage(initialState: draft),
                  ));
                },
                onDeletePressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        backgroundColor: AppColors.backgroundColor,
                        title: const Text('Hapus Draft'),
                        content: Text(
                            'Apakah Anda yakin ingin menghapus draft "${draft.namaUlok ?? '(Tanpa Nama)'}"?'),
                        actions: <Widget>[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              side: const BorderSide(color: AppColors.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              // Panggil repository langsung & refresh provider
                              await ref.read(ulokFormRepositoryProvider).deleteDraft(draft.localId);
                              ref.invalidate(ulokDraftsProvider);
                                                          // ignore: use_build_context_synchronously
                              Navigator.of(dialogContext).pop(); 
                            },
                            child: const Text('Hapus'),
                          ),
                        ]
                      );
                    },
                  );
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

