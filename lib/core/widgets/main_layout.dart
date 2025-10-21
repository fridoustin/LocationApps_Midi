import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/error_screens/under_maintenance_screen.dart';
import 'package:midi_location/features/home/presentation/pages/home_screen.dart';
import 'package:midi_location/features/lokasi/presentation/pages/lokasi_mainscreen.dart';
import 'package:midi_location/features/notification/presentation/provider/notification_provider.dart';
import 'package:midi_location/features/profile/presentation/pages/profile_screen.dart';
import 'package:midi_location/core/widgets/navigation/navigation_bar.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_form_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_form_provider.dart';
import 'package:midi_location/features/error_screens/no_connection_screen.dart';

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
    LokasiMainPage(),
    UnderMaintenanceScreen(),
    ProfilePage(),
  ];

  final List<String> _pageTitles = [
    'Home',
    'Lokasi',
    'Tugas',
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

  PreferredSizeWidget _buildAppBar(int index, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return userProfileAsync.when(
      data: (profile) {
        switch (index) {
          case 0:
            if (profile == null) {
              return CustomTopBar.home(
                profileData: profile,
                unreadNotificationCount: unreadCount,
              );
            }
            return CustomTopBar.home(
              profileData: profile,
              unreadNotificationCount: unreadCount,
            );
          case 3:
            if (profile == null) {
              return CustomTopBar.general(
                title: _pageTitles[index],
                unreadNotificationCount: unreadCount,
              );
            }
            return CustomTopBar.profile(
              profileData: profile,
              title: _pageTitles[index],
              unreadNotificationCount: unreadCount,
            );
          default:
            return CustomTopBar.general(
              title: _pageTitles[index],
              profileData: profile,
              unreadNotificationCount: unreadCount,
            );
        }
      },
      loading: () {
        switch (index) {
          case 0:
            return CustomTopBar.home();
          case 3:
            return CustomTopBar.general(title: '');
          default:
            return CustomTopBar.general(title: '');
        }
      },
      error: (err, stack) {
        switch (index) {
          case 0:
            return CustomTopBar.home();
          case 3:
            return CustomTopBar.general(title: 'Gagal Memuat Profil');
          default:
            return CustomTopBar.general(title: _pageTitles[index]);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityStatus = ref.watch(connectivityProvider);
    return connectivityStatus.when(
      data: (result) {
        if (result == ConnectivityResult.none) {
          return Scaffold(
            body: NoConnectionScreen(
              onRefresh: () {
                ref.invalidate(connectivityProvider);
              },
              onGoToOfflineForm: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UlokFormPage()),
                );
              },
            ),
          );
        }

        return WillPopScope(
          onWillPop: () async {
            if (_currentIndex != 0) {
              setState(() => _currentIndex = 0);
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: _buildAppBar(_currentIndex, ref),
            body: IndexedStack(index: _currentIndex, children: _pages),
            bottomNavigationBar: NavigationBarWidget(
              currentIndex: _currentIndex,
              onItemTapped: _onItemTapped,
              onCenterButtonTapped: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UlokFormPage()),
                );
              },
            ),
            backgroundColor: AppColors.backgroundColor,
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Gagal memuat status koneksi: $err'),
        ),
      ),
    );
  }
}
