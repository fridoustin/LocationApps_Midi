// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/formkplt_screen.dart';
import 'package:midi_location/features/home/presentation/pages/home_screen.dart';
import 'package:midi_location/features/profile/presentation/pages/profile_screen.dart';
import 'package:midi_location/features/ulok/presentation/pages/ulok_screen.dart';
import 'package:midi_location/core/widgets/navigation/navigation_bar.dart';

class MainLayout extends ConsumerStatefulWidget {
  final int currentIndex;

  const MainLayout({super.key, this.currentIndex = 0});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    ULOKPage(),
    FormKPLTPage(),
    ProfilePage(),
  ];

  final List<String> _pageTitles = [
    'Home',
    'Usulan Lokasi',
    'Form KPLT',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    return WillPopScope(
      onWillPop: () async {
        // kalau bukan di home, balik dulu ke home
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: _currentIndex == 0
          ? userProfileAsync.when(
              data: (profile) => CustomTopBar.home(
                branchName: profile?.branchName ?? 'Branch',
              ),
              loading: () => CustomTopBar.home(
                branchName: 'Memuat...',
              ),
              error: (err, stack) => CustomTopBar.general(
                title: 'Gagal Memuat Data',
              ),
            )
          // Jika halaman lain
          : CustomTopBar.general(
              title: _pageTitles[_currentIndex],
            ),
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: NavigationBarWidget(
          currentIndex: _currentIndex,
          onItemTapped: _onItemTapped,
          onCenterButtonTapped: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Center button tapped')),
            );
          },
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
    );
  }
}
