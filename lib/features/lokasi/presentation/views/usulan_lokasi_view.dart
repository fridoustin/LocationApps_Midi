import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_filter.dart';
import 'package:midi_location/features/lokasi/domain/entities/ulok_form_state.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_form_page.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_form_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/ulok_card.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_provider.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/ulok_filter_dialog.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/ulok_list_skeleton.dart';
import 'package:midi_location/features/lokasi/presentation/widgets/ulok_draft_card.dart';

final usulanLokasiSubTabProvider = StateProvider<int>((ref) => 0);

class UsulanLokasiView extends ConsumerStatefulWidget {
  const UsulanLokasiView({super.key});

  @override
  ConsumerState<UsulanLokasiView> createState() => _UsulanLokasiViewState();
}

class _UsulanLokasiViewState extends ConsumerState<UsulanLokasiView>
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

  void _onSubTabChanged(int index) {
    ref.read(usulanLokasiSubTabProvider.notifier).state = index;
    
    if (index == 0) {
      ref.read(ulokTabProvider.notifier).state = UlokTab.recent;
    } else if (index == 1) {
      ref.read(ulokTabProvider.notifier).state = UlokTab.history;
    }
    
    ref.read(ulokSearchQueryProvider.notifier).state = '';
    _searchController.clear();
  }

  int _computeFilterBadgeCount(UlokFilter filter) {
    int c = 0;
    if (filter.status != null) c++;
    if (filter.year != null) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentFilter = ref.watch(ulokFilterProvider);
    final badgeCount = _computeFilterBadgeCount(currentFilter);
    final currentSubTab = ref.watch(usulanLokasiSubTabProvider);
    final isDraftTab = currentSubTab == 2;

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _buildSubTabBar(currentSubTab),
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
                      decoration: InputDecoration(
                        hintText: isDraftTab ? 'Search Draft' : 'Search Ulok',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.cardColor,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () async {
                      final current = ref.read(ulokFilterProvider);
                      final newFilter = await showModalBottomSheet<UlokFilter>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => UlokFilterDialog(initialFilter: current),
                      );

                      if (newFilter != null) {
                        ref.read(ulokFilterProvider.notifier).state = newFilter;
                        ref.invalidate(ulokListProvider);
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
        ),
        Positioned(
          bottom: 16, 
          right: 16,  
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const UlokFormPage(),
              ));
            },
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            child: SvgPicture.asset(
              'assets/icons/addulok.svg',
              width: 32,
              height: 32,
              ),
          ),
        ),
      ]
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
            final tabWidth = constraints.maxWidth / 3;

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
                    _buildSubTab('Draft', 2, tabWidth, currentIndex),
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
        return _buildRecentList();
      case 1:
        return _buildHistoryList();
      case 2:
        return _buildDraftsList();
      default:
        return _buildRecentList();
    }
  }

  Widget _buildRecentList() {
    final ulokListAsync = ref.watch(ulokListProvider);
    return ulokListAsync.when(
      data: (ulokList) {
        if (ulokList.isEmpty) {
          return const Center(child: Text('Tidak ada data ULok Recent.'));
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

  Widget _buildHistoryList() {
    final ulokListAsync = ref.watch(ulokListProvider);
    return ulokListAsync.when(
      data: (ulokList) {
        if (ulokList.isEmpty) {
          return const Center(child: Text('Tidak ada data ULok History.'));
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
              return UlokDraftCardNew(
                draft: draft,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UlokFormPage(initialState: draft),
                  ));
                },
                onContinue: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UlokFormPage(initialState: draft),
                  ));
                },
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        backgroundColor: AppColors.backgroundColor,
                        title: const Text('Hapus Draft'),
                        content: Text(
                          'Apakah Anda yakin ingin menghapus draft "${draft.namaUlok ?? '(Tanpa Nama)'}"?',
                        ),
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
                              await ref.read(ulokFormRepositoryProvider).deleteDraft(draft.localId);
                              ref.invalidate(ulokDraftsProvider);
                              // ignore: use_build_context_synchronously
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Hapus'),
                          ),
                        ],
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