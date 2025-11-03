import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/home/presentation/pages/home_screen.dart';
import 'package:midi_location/features/lokasi/presentation/pages/lokasi_mainscreen.dart';
import 'package:midi_location/features/notification/presentation/provider/notification_provider.dart';
import 'package:midi_location/features/penugasan/presentation/pages/penugasan_main_page.dart';
import 'package:midi_location/core/widgets/navigation/navigation_bar.dart';
import 'package:midi_location/features/lokasi/presentation/pages/ulok_form_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_form_provider.dart';
import 'package:midi_location/features/error_screens/no_connection_screen.dart';
import 'package:midi_location/features/statistik/presentation/pages/statistik_screen.dart';

final mainNavigationProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerStatefulWidget {
  final int currentIndex;
  const MainLayout({super.key, this.currentIndex = 0});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final List<Widget> _pages = const [
    HomeScreen(),
    LokasiMainPage(),
    PenugasanMainPage(),
    StatistikScreen(),
  ];

  final List<String> _pageTitles = ['Home', 'Lokasi', 'Tugas', 'Statistik'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainNavigationProvider.notifier).state = widget.currentIndex;
    });
  }

  void _onItemTapped(int index) {
    ref.read(mainNavigationProvider.notifier).state = index;
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
          default:
            return CustomTopBar.general(title: '');
        }
      },
      error: (err, stack) {
        switch (index) {
          case 0:
            return CustomTopBar.home();
          default:
            return CustomTopBar.general(title: _pageTitles[index]);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainNavigationProvider);

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
            if (currentIndex != 0) {
              ref.read(mainNavigationProvider.notifier).state = 0;
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: _buildAppBar(currentIndex, ref),
            body: IndexedStack(index: currentIndex, children: _pages),
            bottomNavigationBar: NavigationBarWidget(
              currentIndex: currentIndex,
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
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, stack) => Scaffold(
            body: Center(child: Text('Gagal memuat status koneksi: $err')),
          ),
    );
  }
}
